#!/usr/bin/env python3
import subprocess
import sys
import shutil
from pathlib import Path
from rich.console import Console
from rich.panel import Panel
from rich.prompt import Prompt

console = Console()

SCRIPT_DIR = Path(__file__).resolve().parent
LOGO_PATH = SCRIPT_DIR / "assets" / "reticulum_logo.png"


def check_chafa():
    if shutil.which("chafa") is None:
        console.print("[yellow]chafa not found, installing...[/yellow]")
        subprocess.run(["sudo", "apt", "install", "-y", "chafa"], check=True)


def show_banner():
    if not LOGO_PATH.exists():
        console.print(f"[yellow](logo not found at {LOGO_PATH} - skipping)[/yellow]")
        return

    # size the logo relative to the real terminal width instead of small box
    term_width = shutil.get_terminal_size().columns
    render_width = min(term_width - 4, 36)
    render_height = int(render_width * 0.5)

    subprocess.run([
        "chafa",
        f"--size={render_width}x{render_height}",
        "--symbols=block",   
        str(LOGO_PATH),
    ])

    console.print("\n[bold cyan]Kairos - Reticulum Deployment Toolkit[/bold cyan]\n")


def show_menu():
    console.print(Panel("Choose an install path:", style="cyan"))
    console.print("  [cyan]1[/cyan]  Client install")
    console.print("  [cyan]2[/cyan]  Server install")
    console.print("  [cyan]3[/cyan]  Exit\n")
    return Prompt.ask("Selection", choices=["1", "2", "3"])


def run_script(script_name):
    script_path = SCRIPT_DIR / script_name
    subprocess.run(["bash", str(script_path)])


def main():
    check_chafa()
    show_banner()
    choice = show_menu()

    if choice == "1":
        run_script("install_client.sh")
    elif choice == "2":
        run_script("install_server.sh")
    else:
        console.print("[cyan]Exiting.[/cyan]")
        sys.exit(0)


if __name__ == "__main__":
    main()