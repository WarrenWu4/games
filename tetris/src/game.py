from settings import *
from random import choice
from timer import Timer

class Game:
    def __init__(self, get_next_shape, update_score):
        self.surface = pygame.Surface((GAME_WIDTH, GAME_HEIGHT))
        self.display_surface = pygame.display.get_surface()
        self.rect = self.surface.get_rect(topleft = (PADDING, PADDING))

        self.line_surface = self.surface.copy()
        self.line_surface.fill((0, 255, 0))
        self.line_surface.set_colorkey((0, 255, 0))
        self.line_surface.set_alpha(120)
        
        self.get_next_shape = get_next_shape

        self.map = [[0 for _ in range(COLUMNS)] for _ in range(ROWS)]
        self.sprites = pygame.sprite.Group()
        self.tetromino = Tetromino(choice(list(TETROMINOS.keys())), self.sprites, self.create_new_tetromino, self.map)
        
        self.timers = {
                'vertical move': Timer(UPDATE_START_SPEED, True, self.move_down),
                'horizontal move': Timer(MOVE_WAIT_TIME),
                'rotate': Timer(ROTATE_WAIT_TIME)
        }
        self.timers['vertical move'].activate()
        
        self.update_score = update_score
        self.current_level = 1
        self.current_score = 0
        self.current_lines = 0

    def calculate_score(self, num_lines):
        self.current_lines += num_lines
        self.current_score += SCORE_DATA[num_lines] * self.current_level

        if self.current_lines / 10 > self.current_level:
            self.current_level += 1
        self.update_score(self.current_lines, self.current_score, self.current_level)

    def timer_update(self):
        for timer in self.timers.values():
            timer.update()

    def create_new_tetromino(self):
        self.check_finished_row()
        self.tetromino = Tetromino(self.get_next_shape(), self.sprites, self.create_new_tetromino, self.map)

    def move_down(self):
        self.tetromino.move_down()

    def draw_grid(self):
        for col in range(1, COLUMNS):
            col *= CELL_SIZE
            surf_height = self.surface.get_height()
            pygame.draw.line(self.line_surface, LINE_COLOR, (col, 0), (col, surf_height), 1)
        for row in range(1, ROWS):
            row *= CELL_SIZE
            surf_width = self.surface.get_width()
            pygame.draw.line(self.line_surface, LINE_COLOR, (0, row), (surf_width, row), 1)
        self.surface.blit(self.line_surface, (0,0))

    def input(self):
        keys = pygame.key.get_pressed()
        if not self.timers['horizontal move'].active:
            if keys[pygame.K_LEFT]:
                self.tetromino.move_horizontal(-1)
                self.timers['horizontal move'].activate()
            if keys[pygame.K_RIGHT]:
                self.tetromino.move_horizontal(1)
                self.timers['horizontal move'].activate()
        if not self.timers['rotate'].active:
            if keys[pygame.K_UP]:
                self.tetromino.rotate()
                self.timers['rotate'].activate()

    def check_finished_row(self):
        delete_rows = []
        for i, row in enumerate(self.map):
            if all(row):
                delete_rows.append(i)

        for delete_row in delete_rows:
            for block in self.map[delete_row]:
                block.kill()
            for row in self.map:
                for block in row:
                    if block and block.pos.y < delete_row:
                        block.pos.y += 1
        self.map = [[0 for _ in range(COLUMNS)] for _ in range(ROWS)]
        for block in self.sprites:
            self.map[int(block.pos.y)][int(block.pos.x)] = block
        if len(delete_rows) != 0:
            self.calculate_score(len(delete_rows))

    def run(self):
        self.input()
        self.timer_update()
        self.sprites.update()

        self.surface.fill(GRAY)
        self.sprites.draw(self.surface)

        self.draw_grid()
        self.display_surface.blit(self.surface, (PADDING, PADDING))
        pygame.draw.rect(self.display_surface, LINE_COLOR, self.rect, 2, 2)

class Tetromino:
    def __init__(self, shape, group, create_new_tetromino, map):
        self.shape = shape
        self.block_positions = TETROMINOS[shape]['shape']
        self.color = TETROMINOS[shape]['color']
        self.create_new_tetromino = create_new_tetromino
        self.map = map

        self.blocks = [Block(group, pos, self.color) for pos in self.block_positions]

    def horizontal_collision(self, blocks, amount):
        collision_list = [block.horizontal_collide(int(block.pos.x+amount), self.map) for block in blocks]
        return any(collision_list)

    def vertical_collision(self, blocks, amount):
        collision_list = [block.vertical_collide(int(block.pos.y+amount), self.map) for block in blocks]
        return any(collision_list)

    def move_down(self):
        if not self.vertical_collision(self.blocks, 1):
            for block in self.blocks:
                block.pos.y += 1
        else:
            for block in self.blocks:
                self.map[int(block.pos.y)][int(block.pos.x)] = block
            self.create_new_tetromino()
    
    def move_horizontal(self, dir):
        if not self.horizontal_collision(self.blocks, dir):
            for block in self.blocks:
                block.pos.x += dir

    def rotate(self):
        if (self.shape == 'O'):
            return
        pivot = self.blocks[0].pos
        new_block_positions = [block.rotate(pivot) for block in self.blocks]
        for pos in new_block_positions:
            if pos.x < 0 or pos.x >= COLUMNS:
                return
            if self.map[int(pos.y)][int(pos.x)]:
                return
            if pos.y > ROWS:
                return
        for i, block in enumerate(self.blocks):
            block.pos = new_block_positions[i]

class Block(pygame.sprite.Sprite):
    def __init__(self, group, pos, color):
        super().__init__(group)
        self.image = pygame.Surface((CELL_SIZE, CELL_SIZE))
        self.image.fill(color)

        self.pos = pygame.Vector2(pos) + BLOCK_OFFSET
        (x, y) = (self.pos.x*CELL_SIZE, self.pos.y*CELL_SIZE)
        self.rect = self.image.get_rect(topleft = (x, y))

    def rotate(self, pivot):
        return pivot + (self.pos - pivot).rotate(90)

    def horizontal_collide(self, x, map):
        if not 0 <= x < COLUMNS:
            return True
        if map[int(self.pos.y)][x]:
            return True
        return False

    def vertical_collide(self, y, map):
        if y >= ROWS:
            return True
        if y >= 0 and map[y][int(self.pos.x)]:
            return True
        return False

    def update(self):
        self.rect.topleft = self.pos * CELL_SIZE
