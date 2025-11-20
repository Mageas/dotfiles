#!/usr/bin/env python3
import argparse
import json
import logging
import signal
import sys
import os
from typing import List, Optional

import gi
gi.require_version("Playerctl", "2.0")
from gi.repository import Playerctl, GLib

logger = logging.getLogger(__name__)

class PlayerManager:
    def __init__(self, selected_player: Optional[str], excluded_players: List[str]):
        self.manager = Playerctl.PlayerManager()
        self.loop = GLib.MainLoop()
        self.selected_player = selected_player
        self.excluded_players = excluded_players

        self.manager.connect("name-appeared", self.on_player_appeared)
        self.manager.connect("player-vanished", self.on_player_vanished)

        self.init_existing_players()

    def run(self):
        logger.info("Starting PlayerManager loop...")
        self.loop.run()

    def init_existing_players(self):
        logger.debug("Initializing existing players...")
        for name in self.manager.props.player_names:
            self.init_player(name)

    def init_player(self, player_name):
        if self.should_exclude(player_name.name):
            logger.debug(f"Ignoring excluded player: {player_name.name}")
            return

        logger.info(f"Registering new player: {player_name.name}")
        player = Playerctl.Player.new_from_name(player_name)
        player.connect("playback-status", self.update_status)
        player.connect("metadata", self.update_status)
        self.manager.manage_player(player)
        self.update_status(player)

    def should_exclude(self, name: str) -> bool:
        if name in self.excluded_players:
            return True
        if self.selected_player and name != self.selected_player:
            return True
        return False

    def on_player_appeared(self, _, player_name):
        logger.info(f"Player appeared: {player_name.name}")
        self.init_player(player_name)

    def on_player_vanished(self, _, player):
        logger.info(f"Player vanished: {player.props.player_name}")
        self.update_output()

    def update_status(self, player, *args):
        logger.debug(f"Status update received from: {player.props.player_name} - State: {player.props.status}")
        self.update_output()

    def get_active_player(self) -> Optional[Playerctl.Player]:
        players = self.manager.props.players
        # Prefer playing players, most recently added first (assuming list is ordered by appearance)
        playing = [p for p in players if p.props.status == "Playing"]
        if playing:
            active = playing[-1]
            logger.debug(f"Active player selected (Playing): {active.props.player_name}")
            return active

        # Fallback to any player if none playing, prefer most recent
        if players:
            active = players[-1]
            logger.debug(f"Active player selected (Fallback): {active.props.player_name}")
            return active

        logger.debug("No active players found.")
        return None

    def update_output(self):
        player = self.get_active_player()
        if not player:
            sys.stdout.write("\n")
            sys.stdout.flush()
            return

        try:
            metadata = player.props.metadata
            artist = player.get_artist()
            title = player.get_title()
            status = player.props.status
            player_name = player.props.player_name
        except Exception as e:
            logger.error(f"Error getting player info: {e}")
            return

        text = ""
        if player_name == "spotify" and "mpris:trackid" in metadata and ":ad:" in metadata["mpris:trackid"]:
            text = "Advertisement"
        elif artist and title:
            text = f"{artist} — {title}"
        else:
            text = title or ""

        if status == "Playing":
            text = f"  {text}"
        elif status == "Paused":
            text = f"  {text}"

        output = {
            "text": text,
            "class": f"custom-{player_name}",
            "alt": player_name
        }

        # Log the output content in debug mode
        logger.debug(f"Outputting JSON: {output}")

        sys.stdout.write(json.dumps(output, ensure_ascii=False) + "\n")
        sys.stdout.flush()

def signal_handler(sig, frame):
    logger.info("Signal received, exiting...")
    sys.exit(0)

def setup_logging(args):
    handlers = []
    log_format = "%(asctime)s %(levelname)s:%(lineno)d %(message)s"

    log_level = logging.WARNING
    if args.verbose == 1:
        log_level = logging.INFO
    elif args.verbose >= 2:
        log_level = logging.DEBUG

    if args.enable_logging:
        home_dir = os.path.expanduser("~")
        log_dir = os.path.join(home_dir, ".local", "state", "waybar-player")
        os.makedirs(log_dir, exist_ok=True)

        logfile = os.path.join(log_dir, "media-player.log")

        file_handler = logging.FileHandler(logfile)
        file_handler.setLevel(log_level)
        handlers.append(file_handler)

    if args.verbose > 0:
        stream_handler = logging.StreamHandler(sys.stderr)
        stream_handler.setLevel(log_level)
        handlers.append(stream_handler)

    if handlers:
        logging.basicConfig(level=log_level, format=log_format, handlers=handlers)
    else:
        logging.basicConfig(level=logging.CRITICAL)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-v", "--verbose", action="count", default=0, help="Increase verbosity (-v for INFO, -vv for DEBUG)")
    parser.add_argument("-x", "--exclude", help="Comma-separated list of excluded players")
    parser.add_argument("--player", help="Specific player to listen to")
    parser.add_argument("--enable-logging", action="store_true", help="Enable logging to file")
    args = parser.parse_args()

    setup_logging(args)

    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)

    excluded = args.exclude.split(',') if args.exclude else []
    manager = PlayerManager(args.player, excluded)
    manager.run()

if __name__ == "__main__":
    main()
