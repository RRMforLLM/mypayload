$pythonInstalled = $false
try {
    $pythonVersion = python --version
    if ($pythonVersion -match "Python 3") {
        $pythonInstalled = $true
    }
} catch {
    # Python not installed
}

if (-not $pythonInstalled) {
    Write-Host "Python not found. Installing Python 3..."
    $pythonUrl = "https://www.python.org/ftp/python/3.10.0/python-3.10.0-amd64.exe"
    $pythonInstaller = "$env:TEMP\python-installer.exe"
    Invoke-WebRequest -Uri $pythonUrl -OutFile $pythonInstaller
    
    Start-Process -FilePath $pythonInstaller -ArgumentList "/quiet", "InstallAllUsers=0", "PrependPath=1" -Wait
    
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}

Write-Host "Installing required packages..."
Start-Process -FilePath "python" -ArgumentList "-m", "pip", "install", "windows-curses" -Wait

$matrixScript = @'
import random
import time
import os
import math
import threading
import curses
from collections import deque

class MatrixEngine:
    def __init__(self):
        self.width = 0
        self.height = 0
        
        self.matrix_chars = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F']
        self.kanji_chars = ['日', '月', '火', '水', '木', '金', '土', '円', '年', '月', '日', '時', '分', '秒', '円']
        self.cyrillic_chars = ['Ж', 'Ф', 'Ц', 'Ч', 'Ш', 'Щ', 'Э', 'Ю', 'Я', 'Д', 'Л', 'Б', 'Ь']
        self.special_chars = ['ϟ', 'ζ', 'Ω', 'λ', 'μ', 'π', 'φ', 'Σ', 'Δ', '¥', '€', '$', '¢', '£', '∞', '≈', '≠', '≤', '≥', '±', '÷', '×']
        
        self.glitch_enabled = True
        self.frequency_waves = True
        self.message_reveal = True
        
        self.hidden_messages = [
            "WAKE UP NEO",
            "THE MATRIX HAS YOU",
            "FOLLOW THE WHITE RABBIT",
            "KNOCK KNOCK",
            "THERE IS NO SPOON",
            "SYSTEM FAILURE",
            "ACCESS GRANTED",
            "DECRYPTION COMPLETE",
            "MAINFRAME BREACHED"
        ]
        
        self.rain_columns = []
        self.glitch_points = []
        self.wave_offset = 0
        self.message_timer = 0
        self.current_message = None
        self.message_position = None
        self.reveal_progress = 0
        
        self.frame_times = deque(maxlen=60)
        self.last_time = time.time()
        
        self.events = []
        self.event_timer = 0
        
        self.palettes = {
            'default': {'chars': self.matrix_chars, 'probability': 0.7},
            'kanji': {'chars': self.kanji_chars, 'probability': 0.1},
            'cyrillic': {'chars': self.cyrillic_chars, 'probability': 0.1},
            'special': {'chars': self.special_chars, 'probability': 0.1}
        }

    def select_char(self):
        r = random.random()
        cumulative = 0
        selected_palette = self.matrix_chars
        
        for palette in self.palettes.values():
            cumulative += palette['probability']
            if r <= cumulative:
                selected_palette = palette['chars']
                break
                
        return random.choice(selected_palette)
    
    def initialize_columns(self):
        self.rain_columns = []
        for i in range(self.width):
            column = {
                'position': random.randint(-20, 0) if random.random() < 0.5 else 0,
                'speed': random.uniform(0.5, 3.0),
                'density': random.randint(5, 25),
                'char_change_prob': random.uniform(0.1, 0.3),
                'brightness': random.uniform(0.7, 1.0),
                'chars': [self.select_char() for _ in range(50)],
                'palette': random.choice(list(self.palettes.keys())),
                'active': random.random() < 0.5
            }
            self.rain_columns.append(column)
    
    def update_matrix(self, delta_time):
        self.wave_offset += delta_time * 2.0
        
        for i, column in enumerate(self.rain_columns):
            if not column['active'] and random.random() < 0.02:
                column['active'] = True
                column['position'] = 0
            
            if column['active']:
                column['position'] += column['speed'] * delta_time * 15
                
                for j in range(len(column['chars'])):
                    if random.random() < column['char_change_prob'] * delta_time * 10:
                        column['chars'][j] = self.select_char()
                
                if column['position'] > self.height + column['density']:
                    if random.random() < 0.2:
                        column['active'] = False
                    else:
                        column['position'] = random.randint(-20, 0)
                        column['speed'] = random.uniform(0.5, 3.0)
                        column['density'] = random.randint(5, 25)
                        column['palette'] = random.choice(list(self.palettes.keys()))
        
        if self.glitch_enabled:
            if random.random() < 0.05:
                new_glitch = {
                    'x': random.randint(0, self.width - 1),
                    'y': random.randint(0, self.height - 1),
                    'width': random.randint(3, 15),
                    'height': random.randint(1, 3),
                    'duration': random.uniform(0.1, 0.5),
                    'timer': 0,
                    'shift': random.randint(-5, 5)
                }
                self.glitch_points.append(new_glitch)
            
            for i in range(len(self.glitch_points) - 1, -1, -1):
                self.glitch_points[i]['timer'] += delta_time
                if self.glitch_points[i]['timer'] >= self.glitch_points[i]['duration']:
                    self.glitch_points.pop(i)
        
        if self.message_reveal:
            self.message_timer += delta_time
            
            if self.current_message is None and random.random() < 0.005:
                self.current_message = random.choice(self.hidden_messages)
                self.message_position = {
                    'x': random.randint(5, self.width - len(self.current_message) - 5),
                    'y': random.randint(5, self.height - 5)
                }
                self.reveal_progress = 0
            
            if self.current_message is not None:
                self.reveal_progress += delta_time * 5
                if self.reveal_progress >= len(self.current_message) + 3:
                    self.current_message = None
        
        self.event_timer += delta_time
        if self.event_timer > 5 and random.random() < 0.01:
            self.trigger_special_event()
            self.event_timer = 0
    
    def trigger_special_event(self):
        event_type = random.choice([
            'cascade', 'clear', 'glitch_intense', 'speed_up', 'matrix_shift'
        ])
        
        if event_type == 'cascade':
            for i in range(self.width):
                if i % 3 == 0:
                    column = self.rain_columns[i]
                    column['active'] = True
                    column['position'] = -i % 10
                    column['speed'] = 2.5
        
        elif event_type == 'clear':
            clear_x = random.randint(0, self.width - 20)
            clear_width = random.randint(10, 30)
            for i in range(clear_x, min(clear_x + clear_width, self.width)):
                self.rain_columns[i]['active'] = False
        
        elif event_type == 'glitch_intense':
            for _ in range(10):
                new_glitch = {
                    'x': random.randint(0, self.width - 1),
                    'y': random.randint(0, self.height - 1),
                    'width': random.randint(3, 30),
                    'height': random.randint(1, 5),
                    'duration': random.uniform(0.3, 1.0),
                    'timer': 0,
                    'shift': random.randint(-10, 10)
                }
                self.glitch_points.append(new_glitch)
        
        elif event_type == 'speed_up':
            for column in self.rain_columns:
                if column['active']:
                    column['speed'] *= 1.5
        
        elif event_type == 'matrix_shift':
            for column in self.rain_columns:
                column['palette'] = random.choice(list(self.palettes.keys()))
        
        self.events.append({
            'type': event_type,
            'time': time.time(),
            'description': f"Event triggered: {event_type}"
        })
    
    def render_frame(self, stdscr):
        stdscr.clear()
        
        self.height, self.width = stdscr.getmaxyx()
        self.height -= 1
        
        if len(self.rain_columns) != self.width:
            self.initialize_columns()
        
        if not hasattr(self, 'colors_initialized'):
            curses.start_color()
            curses.use_default_colors()
            for i in range(1, 16):
                curses.init_pair(i, i, -1)
            curses.init_pair(16, curses.COLOR_WHITE, -1)
            curses.init_pair(17, curses.COLOR_CYAN, -1)
            curses.init_pair(18, curses.COLOR_YELLOW, -1)
            curses.init_pair(19, curses.COLOR_RED, -1)
            self.colors_initialized = True
        
        wave_values = []
        if self.frequency_waves:
            for i in range(self.width):
                wave1 = math.sin(i * 0.1 + self.wave_offset) * 0.5
                wave2 = math.sin(i * 0.05 - self.wave_offset * 0.7) * 0.3
                wave3 = math.sin(i * 0.02 + self.wave_offset * 0.3) * 0.2
                composite_wave = wave1 + wave2 + wave3
                wave_values.append(int((composite_wave + 1) * self.height * 0.5))
        
        for x in range(min(self.width, len(self.rain_columns))):
            column = self.rain_columns[x]
            
            if not column['active']:
                continue
            
            wave_offset = 0
            if self.frequency_waves and x < len(wave_values):
                wave_offset = wave_values[x] * 0.1
            
            head_pos = int(column['position'] + wave_offset)
            
            if 0 <= head_pos < self.height:
                char = column['chars'][0]
                stdscr.addstr(head_pos, x, char, curses.color_pair(10) | curses.A_BOLD)
            
            for j in range(1, min(column['density'], len(column['chars']))):
                pos = head_pos - j
                if 0 <= pos < self.height:
                    char = column['chars'][j % len(column['chars'])]
                    
                    brightness_factor = max(0, 1 - (j / column['density']))
                    color_index = max(1, min(8, int(brightness_factor * 8)))
                    
                    if column['palette'] == 'kanji':
                        color_pair = 17
                    elif column['palette'] == 'special':
                        color_pair = 16
                    else:
                        color_pair = color_index
                    
                    stdscr.addstr(pos, x, char, curses.color_pair(color_pair))
        
        for glitch in self.glitch_points:
            for y in range(glitch['y'], min(glitch['y'] + glitch['height'], self.height)):
                for x in range(glitch['x'], min(glitch['x'] + glitch['width'], self.width)):
                    if random.random() < 0.7:
                        shifted_x = (x + glitch['shift']) % self.width
                        if 0 <= shifted_x < self.width and 0 <= y < self.height:
                            char = random.choice(self.special_chars)
                            stdscr.addstr(y, shifted_x, char, curses.color_pair(19) | curses.A_BOLD)
        
        if self.current_message is not None:
            chars_to_show = min(len(self.current_message), int(self.reveal_progress))
            
            if chars_to_show > 0:
                for i in range(chars_to_show):
                    x = self.message_position['x'] + i
                    y = self.message_position['y']
                    
                    if 0 <= x < self.width and 0 <= y < self.height:
                        if random.random() < 0.9:
                            stdscr.addstr(y, x, self.current_message[i], 
                                         curses.color_pair(18) | curses.A_BOLD)
        
        current_time = time.time()
        delta_time = current_time - self.last_time
        self.last_time = current_time
        
        self.frame_times.append(delta_time)
        fps = 1.0 / (sum(self.frame_times) / len(self.frame_times))
        
        status_line = f"FPS: {fps:.1f} | Columns: {sum(1 for c in self.rain_columns if c['active'])}/{len(self.rain_columns)} | Glitches: {len(self.glitch_points)} | Event: {self.events[-1]['type'] if self.events else 'None'}"
        status_attr = curses.color_pair(16) | curses.A_DIM
        
        try:
            stdscr.addstr(self.height, 0, status_line[:self.width-1], status_attr)
        except curses.error:
            pass
        
        stdscr.refresh()
        
        return delta_time

def run_matrix_simulation(stdscr):
    curses.curs_set(0)
    stdscr.nodelay(True)
    stdscr.timeout(20)
    
    matrix = MatrixEngine()
    
    random.seed(time.time())
    
    key_bindings = {
        'g': lambda: toggle_attribute(matrix, 'glitch_enabled'),
        'w': lambda: toggle_attribute(matrix, 'frequency_waves'),
        'm': lambda: toggle_attribute(matrix, 'message_reveal'),
        'c': lambda: matrix.trigger_special_event(),
        'q': lambda: sys.exit(0)
    }
    
    def toggle_attribute(obj, attr):
        setattr(obj, attr, not getattr(obj, attr))
    
    last_time = time.time()
    try:
        while True:
            key = stdscr.getch()
            if key != -1:
                key_char = chr(key) if 0 <= key <= 255 else ''
                if key_char in key_bindings:
                    key_bindings[key_char]()
            
            current_time = time.time()
            delta_time = current_time - last_time
            last_time = current_time
            
            matrix.update_matrix(delta_time)
            
            matrix.render_frame(stdscr)
            
            frame_time = time.time() - current_time
            sleep_time = max(0.01, 0.033 - frame_time)
            time.sleep(sleep_time)
    
    except KeyboardInterrupt:
        return

def decryption_animation():
    width = 80
    lines = [
        "INITIALIZING NEURAL INTERFACE...",
        "ESTABLISHING SECURE CONNECTION...",
        "BYPASSING FIREWALL PROTOCOLS...",
        "QUANTUM ENCRYPTION DETECTED...",
        "DEPLOYING POLYMORPHIC DECRYPTION ALGORITHMS...",
        "MATRIX ENTRY POINT LOCATED...",
        "TRAVERSING NETWORK TOPOLOGY...",
        "COMPILING BINARY TRANSLATORS...",
        "OVERRIDING SECURITY SUBSYSTEMS...",
        "LAUNCHING NEURAL MATRIX VISUALIZATION..."
    ]
    
    os.system('cls' if os.name == 'nt' else 'clear')
    
    for line in lines:
        print(f"\033[92m{line}\033[0m")
        time.sleep(0.3)
        
        for _ in range(3):
            code_line = ''.join(random.choice(['0', '1']) for _ in range(width))
            print(f"\033[32m{code_line}\033[0m")
            time.sleep(0.1)
    
    print("\n\033[97mMATRIX ENTRY SUCCESSFUL\033[0m")
    print("\033[93mControls: g=toggle glitch, w=toggle waves, m=toggle messages, c=trigger event, q=quit\033[0m")
    time.sleep(1)

if __name__ == "__main__":
    import sys
    
    decryption_animation()
    
    try:
        curses.wrapper(run_matrix_simulation)
    except KeyboardInterrupt:
        print("\033[0m\nConnection terminated. Exiting Matrix...")
    except Exception as e:
        print(f"\033[0m\nError: {e}")
        import traceback
        traceback.print_exc()
'@

$matrixScriptPath = "$env:TEMP\matrix_simulation.py"
$matrixScript | Out-File -FilePath $matrixScriptPath -Encoding utf8

Write-Host "Running Matrix Visualization..."
Start-Process -FilePath "powershell" -ArgumentList "-WindowStyle Maximized", "-Command", "python $matrixScriptPath"
