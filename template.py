import os
import sys

from pathlib import Path

def to_interface(version):
	return 10000 * int(version[0]) + 100 * int(version[2]);

class Addon:
	def __init__(self, author, name, version, theme):
		self.author    = author;
		self.name      = name;
		self.interface = to_interface(version);
		self.theme     = theme;

		self.directory = Path(self.name);

		self.make();

	def make(self):
		os.mkdir(self.name);
		self.make_table_of_contents();
		self.make_config();
		self.make_init();
		self.make_changelog();

	def make_table_of_contents(self):
		with open('toc.template', 'r') as f:
			template = f.read();

		with open(self.directory / (self.name + '.toc'), 'w') as f:
			f.write(template.format(
				colour    = self.theme,
				addon     = self.name,
				interface = self.interface,
				author    = self.author));

	def make_config(self):
		with open('config.template', 'r') as f:
			template = f.read();

		with open(self.directory / 'config.lua', 'w') as f:
			f.write(template.format(
				namespace = self.name,
				## Theme
				r = int(self.theme[0:2], 16) / 255.0,
				g = int(self.theme[2:4], 16) / 255.0,
				b = int(self.theme[4:6], 16) / 255.0,
				hex = self.theme,
				## Info
				name      = self.name,
				interface = self.interface,
				major = 0,
				minor = 1,
				stage = 'alpha',
				author = self.author));

	def make_init(self):
		with open('init.template', 'r') as f:
			template = f.read();

		with open(self.directory / 'init.lua', 'w') as f:
			f.write(template.format(
				namespace = self.name));

	def make_changelog(self):
		with open(self.directory / 'CHANGELOG', 'w') as f:
			pass

	def debug(self):
		print(f'Created addon {self.name} by {self.author}.');
		print(f'Game version: {self.interface}');
		print(f'Theme: {self.theme}');

addon = Addon(
	author  = sys.argv[1],
	name    = sys.argv[2],
	version = sys.argv[3],
	theme   = sys.argv[4]);
addon.debug();
