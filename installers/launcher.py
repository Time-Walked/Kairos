#!/usr/bin/env python3
import subprocess
import sys
import readline  # noqa: F401 - enables proper line editing (arrow keys,
                  # backspace) in input(), otherwise arrow keys print raw
                  # escape codes into the prompt
from pathlib import Path
from rich.console import Console
from rich.panel import Panel
from rich.prompt import Prompt

console = Console()

SCRIPT_DIR = Path(__file__).resolve().parent


def show_banner():
    console.print("[bold #7d5ba6]Reticulum Deployment Toolkit[/bold #7d5ba6]\n")


def show_menu():
    console.print(Panel("Choose an install path:", border_style="#7d5ba6"))
    console.print("  [#c9c3d9]1[/#c9c3d9]  Client install")
    console.print("  [#c9c3d9]2[/#c9c3d9]  Server install")
    console.print("  [#c9c3d9]3[/#c9c3d9]  Add an interface")
    console.print("  [#c9c3d9]4[/#c9c3d9]  Exit\n")
    return Prompt.ask("Selection", choices=["1", "2", "3", "4"])


def run_script(script_name: str):
    script_path = SCRIPT_DIR / script_name
    subprocess.run(["bash", str(script_path)])


def main():
    show_banner()
    choice = show_menu()

    if choice == "1":
        run_script("install_client.sh")
    elif choice == "2":
        run_script("install_server.sh")
    elif choice == "3":
        run_script("add_interface.sh")
    else:
        console.print("[#7d5ba6]Exiting.[/#7d5ba6]")
        sys.exit(0)


if __name__ == "__main__":
    main()