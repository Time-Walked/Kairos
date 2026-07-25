#!/usr/bin/env python3
import subprocess
import sys
import shutil
import readline
from pathlib import Path
from rich.console import Console
from rich.panel import Panel
from rich.prompt import Prompt

console = Console()

SCRIPT_DIR = Path(__file__).resolve().parent
LOGO_PATH = SCRIPT_DIR / "assets" / "reticulum_logo.png"
FLAT_LOGO_PATH = SCRIPT_DIR / "assets" / ".reticulum_logo_flat.png"


def ensure_dependencies():
    if shutil.which("chafa") is None:
        console.print("[yellow]chafa not found, installing...[/yellow]")
        subprocess.run(["sudo", "apt", "install", "-y", "chafa"], check=True)
    try:
        import PIL  # noqa: F401
    except ImportError:
        console.print("[yellow]Pillow not found, installing...[/yellow]")
        subprocess.run(
            ["pip3", "install", "pillow", "--break-system-packages", "--user"],
            check=True,
        )


def flatten_logo():
    from PIL import Image

    img = Image.open(LOGO_PATH).convert("RGBA")
    bg = Image.new("RGBA", img.size, (0, 0, 0, 255))
    flat = Image.alpha_composite(bg, img).convert("RGB")
    flat.save(FLAT_LOGO_PATH)


def show_banner():
    if LOGO_PATH.exists():
        try:
            flatten_logo()
            subprocess.run([
                "chafa",
                "--size=32x16",
                "--colors=full",
                str(FLAT_LOGO_PATH),
            ], check=True)
        except Exception:
            console.print("[yellow](logo render failed - continuing without it)[/yellow]")

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
    ensure_dependencies()
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
