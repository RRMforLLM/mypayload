# PowerShell script to deploy Matrix visualization
# This script downloads Python if not installed, then downloads and runs the Matrix script

# Check if Python is installed
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
    # Download Python 3 installer
    $pythonUrl = "https://www.python.org/ftp/python/3.10.0/python-3.10.0-amd64.exe"
    $pythonInstaller = "$env:TEMP\python-installer.exe"
    Invoke-WebRequest -Uri $pythonUrl -OutFile $pythonInstaller
    
    # Install Python silently
    Start-Process -FilePath $pythonInstaller -ArgumentList "/quiet", "InstallAllUsers=0", "PrependPath=1" -Wait
    
    # Refresh environment path
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}

# Install required Python packages
Write-Host "Installing required packages..."
Start-Process -FilePath "python" -ArgumentList "-m", "pip", "install", "windows-curses" -Wait

# Download the Matrix script
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
        # Terminal setup will be handled by curses
        self.width = 0
        self.height = 0
        
        # Extended character sets
        self.matrix_chars = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F']
        self.kanji_chars = ['日', '月', '火', '水', '木', '金', '土', '円', '年', '月', '日', '時', '分', '秒', '円']
        self.cyrillic_chars = ['Ж', 'Ф', 'Ц', 'Ч', 'Ш', 'Щ', 'Э', 'Ю', 'Я', 'Д', 'Л', 'Б', 'Ь']
        self.special_chars = ['ϟ', 'ζ', 'Ω', 'λ', 'μ', 'π', 'φ', 'Σ', 'Δ', '¥', '€', '$', '¢', '£', '∞', '≈', '≠', '≤', '≥', '±', '÷', '×']
        
        # Special effects
        self.glitch_enabled = True
        self.frequency_waves = True
        self.message_reveal = True
        
        # Hidden messages that will occasionally be revealed in the matrix
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
        
        # Animation state
        self.rain_columns = []
        self.glitch_points = []
        self.wave_offset = 0
        self.message_timer = 0
        self.current_message = None
        self.message_position = None
        self.reveal_progress = 0
        
        # Performance metrics
        self.frame_times = deque(maxlen=60)
        self.last_time = time.time()
        
        # Event systems
        self.events = []
        self.event_timer = 0
        
        # Character palette system
        self.palettes = {
            'default': {'chars': self.matrix_chars, 'probability': 0.7},
            'kanji': {'chars': self.kanji_chars, 'probability': 0.1},
            'cyrillic': {'chars': self.cyrillic_chars, 'probability': 0.1},
            'special': {'chars': self.special_chars, 'probability': 0.1}
        }

    def select_char(self):
        # Select character palette based on probability
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
        # Update wave effect
        self.wave_offset += delta_time * 2.0
        
        # Update columns
        for i, column in enumerate(self.rain_columns):
            if not column['active'] and random.random() < 0.02:
                column['active'] = True
                column['position'] = 0
            
            if column['active']:
                # Update position based on speed and delta_time
                column['position'] += column['speed'] * delta_time * 15
                
                # Randomly change characters in the stream
                for j in range(len(column['chars'])):
                    if random.random() < column['char_change_prob'] * delta_time * 10:
                        column['chars'][j] = self.select_char()
                
                # Reset column if it goes off screen
                if column['position'] > self.height + column['density']:
                    if random.random() < 0.2:  # 20% chance to deactivate
                        column['active'] = False
                    else:
                        column['position'] = random.randint(-20, 0)
                        column['speed'] = random.uniform(0.5, 3.0)
                        column['density'] = random.randint(5, 25)
                        column['palette'] = random.choice(list(self.palettes.keys()))
        
        # Update glitch effect
        if self.glitch_enabled:
            # Randomly create new glitch points
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
            
            # Update existing glitch points
            for i in range(len(self.glitch_points) - 1, -1, -1):
                self.glitch_points[i]['timer'] += delta_time
                if self.glitch_points[i]['timer'] >= self.glitch_points[i]['duration']:
                    self.glitch_points.pop(i)
        
        # Handle message reveal
        if self.message_reveal:
            self.message_timer += delta_time
            
            # Start a new message reveal
            if self.current_message is None and random.random() < 0.005:
                self.current_message = random.choice(self.hidden_messages)
                self.message_position = {
                    'x': random.randint(5, self.width - len(self.current_message) - 5),
                    'y': random.randint(5, self.height - 5)
                }
                self.reveal_progress = 0
            
            # Update ongoing message reveal
            if self.current_message is not None:
                self.reveal_progress += delta_time * 5
                if self.reveal_progress >= len(self.current_message) + 3:  # +3 for additional display time
                    self.current_message = None
        
        # Handle special events
        self.event_timer += delta_time
        if self.event_timer > 5 and random.random() < 0.01:  # Trigger event every ~5-10 seconds
            self.trigger_special_event()
            self.event_timer = 0
    
    def trigger_special_event(self):
        event_type = random.choice([
            'cascade', 'clear', 'glitch_intense', 'speed_up', 'matrix_shift'
        ])
        
        if event_type == 'cascade':
            # Create a cascading wave of activation
            for i in range(self.width):
                if i % 3 == 0:  # Activate every third column
                    column = self.rain_columns[i]
                    column['active'] = True
                    column['position'] = -i % 10  # Staggered start positions
                    column['speed'] = 2.5  # Faster speed
        
        elif event_type == 'clear':
            # Clear sections to create visual interest
            clear_x = random.randint(0, self.width - 20)
            clear_width = random.randint(10, 30)
            for i in range(clear_x, min(clear_x + clear_width, self.width)):
                self.rain_columns[i]['active'] = False
        
        elif event_type == 'glitch_intense':
            # Create many glitches at once
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
            # Temporarily speed up all columns
            for column in self.rain_columns:
                if column['active']:
                    column['speed'] *= 1.5
        
        elif event_type == 'matrix_shift':
            # Shift character palettes for visual variety
            for column in self.rain_columns:
                column['palette'] = random.choice(list(self.palettes.keys()))
        
        # Add the event to the event log
        self.events.append({
            'type': event_type,
            'time': time.time(),
            'description': f"Event triggered: {event_type}"
        })
    
    def render_frame(self, stdscr):
        # Clear the screen
        stdscr.clear()
        
        # Get current dimensions
        self.height, self.width = stdscr.getmaxyx()
        self.height -= 1  # Adjust for status bar
        
        # Make sure we have the right number of columns
        if len(self.rain_columns) != self.width:
            self.initialize_columns()
        
        # Initialize color pairs if not done
        if not hasattr(self, 'colors_initialized'):
            curses.start_color()
            curses.use_default_colors()
            for i in range(1, 16):
                # Initialize color pairs for different brightness levels of green
                curses.init_pair(i, i, -1)
            # Special colors
            curses.init_pair(16, curses.COLOR_WHITE, -1)  # White for special chars
            curses.init_pair(17, curses.COLOR_CYAN, -1)   # Cyan for kanji
            curses.init_pair(18, curses.COLOR_YELLOW, -1) # Yellow for highlighted messages
            curses.init_pair(19, curses.COLOR_RED, -1)    # Red for alerts
            self.colors_initialized = True
        
        # Calculate wave values for the frequency effect
        wave_values = []
        if self.frequency_waves:
            for i in range(self.width):
                # Generate complex wave pattern
                wave1 = math.sin(i * 0.1 + self.wave_offset) * 0.5
                wave2 = math.sin(i * 0.05 - self.wave_offset * 0.7) * 0.3
                wave3 = math.sin(i * 0.02 + self.wave_offset * 0.3) * 0.2
                composite_wave = wave1 + wave2 + wave3
                wave_values.append(int((composite_wave + 1) * self.height * 0.5))
        
        # Render each column
        for x in range(min(self.width, len(self.rain_columns))):
            column = self.rain_columns[x]
            
            if not column['active']:
                continue
            
            # Calculate wave effect on position
            wave_offset = 0
            if self.frequency_waves and x < len(wave_values):
                wave_offset = wave_values[x] * 0.1
            
            head_pos = int(column['position'] + wave_offset)
            
            # Draw the head of the column
            if 0 <= head_pos < self.height:
                char = column['chars'][0]
                # Use a brighter green for the head character
                stdscr.addstr(head_pos, x, char, curses.color_pair(10) | curses.A_BOLD)
            
            # Draw the trailing characters
            for j in range(1, min(column['density'], len(column['chars']))):
                pos = head_pos - j
                if 0 <= pos < self.height:
                    char = column['chars'][j % len(column['chars'])]
                    
                    # Calculate brightness based on position in the trail
                    brightness_factor = max(0, 1 - (j / column['density']))
                    color_index = max(1, min(8, int(brightness_factor * 8)))
                    
                    # Different color schemes based on character type
                    if column['palette'] == 'kanji':
                        color_pair = 17
                    elif column['palette'] == 'special':
                        color_pair = 16
                    else:
                        color_pair = color_index
                    
                    stdscr.addstr(pos, x, char, curses.color_pair(color_pair))
        
        # Apply glitch effects
        for glitch in self.glitch_points:
            for y in range(glitch['y'], min(glitch['y'] + glitch['height'], self.height)):
                for x in range(glitch['x'], min(glitch['x'] + glitch['width'], self.width)):
                    # Only modify some pixels in the glitch area
                    if random.random() < 0.7:
                        shifted_x = (x + glitch['shift']) % self.width
                        if 0 <= shifted_x < self.width and 0 <= y < self.height:
                            char = random.choice(self.special_chars)
                            stdscr.addstr(y, shifted_x, char, curses.color_pair(19) | curses.A_BOLD)
        
        # Render hidden message if active
        if self.current_message is not None:
            chars_to_show = min(len(self.current_message), int(self.reveal_progress))
            
            if chars_to_show > 0:
                for i in range(chars_to_show):
                    x = self.message_position['x'] + i
                    y = self.message_position['y']
                    
                    if 0 <= x < self.width and 0 <= y < self.height:
                        # Flicker effect on the message
                        if random.random() < 0.9:  # 90% chance to show each character
                            stdscr.addstr(y, x, self.current_message[i], 
                                         curses.color_pair(18) | curses.A_BOLD)
        
        # Draw status bar
        current_time = time.time()
        delta_time = current_time - self.last_time
        self.last_time = current_time
        
        self.frame_times.append(delta_time)
        fps = 1.0 / (sum(self.frame_times) / len(self.frame_times))
        
        # Render debug/status information at the bottom of the screen
        status_line = f"FPS: {fps:.1f} | Columns: {sum(1 for c in self.rain_columns if c['active'])}/{len(self.rain_columns)} | Glitches: {len(self.glitch_points)} | Event: {self.events[-1]['type'] if self.events else 'None'}"
        status_attr = curses.color_pair(16) | curses.A_DIM
        
        try:
            stdscr.addstr(self.height, 0, status_line[:self.width-1], status_attr)
        except curses.error:
            # Handle potential curses error when writing to bottom-right corner
            pass
        
        # Refresh the screen
        stdscr.refresh()
        
        # Return actual time elapsed for consistent animation speed
        return delta_time

def run_matrix_simulation(stdscr):
    # Set up curses
    curses.curs_set(0)  # Hide cursor
    stdscr.nodelay(True)  # Non-blocking input
    stdscr.timeout(20)   # Set timeout for getch()
    
    # Create matrix engine
    matrix = MatrixEngine()
    
    # Initialize RNG for better randomness
    random.seed(time.time())
    
    # Track special key combinations
    key_bindings = {
        'g': lambda: toggle_attribute(matrix, 'glitch_enabled'),
        'w': lambda: toggle_attribute(matrix, 'frequency_waves'),
        'm': lambda: toggle_attribute(matrix, 'message_reveal'),
        'c': lambda: matrix.trigger_special_event(),
        'q': lambda: sys.exit(0)
    }
    
    def toggle_attribute(obj, attr):
        setattr(obj, attr, not getattr(obj, attr))
    
    # Main loop
    last_time = time.time()
    try:
        while True:
            # Handle input
            key = stdscr.getch()
            if key != -1:
                key_char = chr(key) if 0 <= key <= 255 else ''
                if key_char in key_bindings:
                    key_bindings[key_char]()
            
            # Calculate delta time for smooth animation
            current_time = time.time()
            delta_time = current_time - last_time
            last_time = current_time
            
            # Update matrix state
            matrix.update_matrix(delta_time)
            
            # Render frame
            matrix.render_frame(stdscr)
            
            # Dynamic sleep to maintain target framerate
            frame_time = time.time() - current_time
            sleep_time = max(0.01, 0.033 - frame_time)  # Target ~30 FPS
            time.sleep(sleep_time)
    
    except KeyboardInterrupt:
        return

# Decryption effect when starting the program
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
        
        # Simulate decryption of code
        for _ in range(3):
            code_line = ''.join(random.choice(['0', '1']) for _ in range(width))
            print(f"\033[32m{code_line}\033[0m")
            time.sleep(0.1)
    
    print("\n\033[97mMATRIX ENTRY SUCCESSFUL\033[0m")
    print("\033[93mControls: g=toggle glitch, w=toggle waves, m=toggle messages, c=trigger event, q=quit\033[0m")
    time.sleep(1)

if __name__ == "__main__":
    import sys
    
    # Start with decryption animation
    decryption_animation()
    
    # Run the matrix simulation
    try:
        curses.wrapper(run_matrix_simulation)
    except KeyboardInterrupt:
        print("\033[0m\nConnection terminated. Exiting Matrix...")
    except Exception as e:
        print(f"\033[0m\nError: {e}")
        import traceback
        traceback.print_exc()
'@

# Save the script to a file
$matrixScriptPath = "$env:TEMP\matrix_simulation.py"
$matrixScript | Out-File -FilePath $matrixScriptPath -Encoding utf8

# Run the script in full screen mode
Write-Host "Running Matrix Visualization..."
Start-Process -FilePath "powershell" -ArgumentList "-WindowStyle Maximized", "-Command", "python $matrixScriptPath"