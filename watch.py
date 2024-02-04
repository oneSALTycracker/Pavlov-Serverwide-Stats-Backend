import time
import subprocess
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

class Watcher:
    def __init__(self, directory_to_watch, script_to_run):
        self.observer = Observer()
        self.directory_to_watch = directory_to_watch
        self.script_to_run = script_to_run

    def run(self):
        event_handler = Handler(self.script_to_run)
        self.observer.schedule(event_handler, self.directory_to_watch, recursive=True)
        self.observer.start()
        try:
            while True:
                time.sleep(5)
        except:
            self.observer.stop()
            print("Observer Stopped")

        self.observer.join()

class Handler(FileSystemEventHandler):
    def __init__(self, script_to_run):
        self.script_to_run = script_to_run

    def on_modified(self, event):
        if not event.is_directory:
            print(f'File modified: {event.src_path}')
            subprocess.call(['bash', self.script_to_run])

if __name__ == '__main__':
    watch_directory = '/home/steam/pavlovserver006/Pavlov/Saved/Config/ModSave/exe.txt'  # match this to your ModSave Running Mod the mod will make a file 'exe.txt' every time the map rotates and this is used to trigger the script to update stats
    bash_script = '/home/steam/pavlovserver006/Pavlov/Saved/Config/ModSave/run.sh'                # this is the actual script that is run when the 'exe.txt' is updated this can be anywhere 
    w = Watcher(watch_directory, bash_script)
    w.run()
