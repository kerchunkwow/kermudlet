# Use this script to find references to Mudlet colors so we can start to abstract/refactor using global color definitions
import os
import re

# Search for references to Mudlet's built-in color table
def search_for_colors():
    color_table = {
      'AliceBlue': [ 240, 248, 255 ],
      'AntiqueWhite': [ 250, 235, 215 ],
      'BlanchedAlmond': [ 255, 235, 205 ],
      'BlueViolet': [ 138, 43, 226 ],
      'CadetBlue': [ 95, 158, 160 ],
      'CornflowerBlue': [ 100, 149, 237 ],
      'DarkGoldenrod': [ 184, 134, 11 ],
      'DarkGreen': [ 0, 100, 0 ],
      'DarkKhaki': [ 189, 183, 107 ],
      'DarkOliveGreen': [ 85, 107, 47 ],
      'DarkOrange': [ 255, 140, 0 ],
      'DarkOrchid': [ 153, 50, 204 ],
      'DarkSalmon': [ 233, 150, 122 ],
      'DarkSeaGreen': [ 143, 188, 143 ],
      'DarkSlateBlue': [ 72, 61, 139 ],
      'DarkSlateGray': [ 47, 79, 79 ],
      'DarkSlateGrey': [ 47, 79, 79 ],
      'DarkTurquoise': [ 0, 206, 209 ],
      'DarkViolet': [ 148, 0, 211 ],
      'DeepPink': [ 255, 20, 147 ],
      'DeepSkyBlue': [ 0, 191, 255 ],
      'DimGray': [ 105, 105, 105 ],
      'DimGrey': [ 105, 105, 105 ],
      'DodgerBlue': [ 30, 144, 255 ],
      'FloralWhite': [ 255, 250, 240 ],
      'ForestGreen': [ 34, 139, 34 ],
      'GhostWhite': [ 248, 248, 255 ],
      'GreenYellow': [ 173, 255, 47 ],
      'HotPink': [ 255, 105, 180 ],
      'IndianRed': [ 205, 92, 92 ],
      'LavenderBlush': [ 255, 240, 245 ],
      'LawnGreen': [ 124, 252, 0 ],
      'LemonChiffon': [ 255, 250, 205 ],
      'LightBlue': [ 173, 216, 230 ],
      'LightCoral': [ 240, 128, 128 ],
      'LightCyan': [ 224, 255, 255 ],
      'LightGoldenrod': [ 238, 221, 130 ],
      'LightGoldenrodYellow': [ 250, 250, 210 ],
      'LightGray': [ 211, 211, 211 ],
      'LightGrey': [ 211, 211, 211 ],
      'LightPink': [ 255, 182, 193 ],
      'LightSalmon': [ 255, 160, 122 ],
      'LightSeaGreen': [ 32, 178, 170 ],
      'LightSkyBlue': [ 135, 206, 250 ],
      'LightSlateBlue': [ 132, 112, 255 ],
      'LightSlateGray': [ 119, 136, 153 ],
      'LightSlateGrey': [ 119, 136, 153 ],
      'LightSteelBlue': [ 176, 196, 222 ],
      'LightYellow': [ 255, 255, 224 ],
      'LimeGreen': [ 50, 205, 50 ],
      'MediumAquamarine': [ 102, 205, 170 ],
      'MediumBlue': [ 0, 0, 205 ],
      'MediumOrchid': [ 186, 85, 211 ],
      'MediumPurple': [ 147, 112, 219 ],
      'MediumSeaGreen': [ 60, 179, 113 ],
      'MediumSlateBlue': [ 123, 104, 238 ],
      'MediumSpringGreen': [ 0, 250, 154 ],
      'MediumTurquoise': [ 72, 209, 204 ],
      'MediumVioletRed': [ 199, 21, 133 ],
      'MidnightBlue': [ 25, 25, 112 ],
      'MintCream': [ 245, 255, 250 ],
      'MistyRose': [ 255, 228, 225 ],
      'NavajoWhite': [ 255, 222, 173 ],
      'NavyBlue': [ 0, 0, 128 ],
      'OldLace': [ 253, 245, 230 ],
      'OliveDrab': [ 107, 142, 35 ],
      'OrangeRed': [ 255, 69, 0 ],
      'PaleGoldenrod': [ 238, 232, 170 ],
      'PaleGreen': [ 152, 251, 152 ],
      'PaleTurquoise': [ 175, 238, 238 ],
      'PaleVioletRed': [ 219, 112, 147 ],
      'PapayaWhip': [ 255, 239, 213 ],
      'PeachPuff': [ 255, 218, 185 ],
      'PowderBlue': [ 176, 224, 230 ],
      'RosyBrown': [ 188, 143, 143 ],
      'RoyalBlue': [ 65, 105, 225 ],
      'SaddleBrown': [ 139, 69, 19 ],
      'SandyBrown': [ 244, 164, 96 ],
      'SeaGreen': [ 46, 139, 87 ],
      'SkyBlue': [ 135, 206, 235 ],
      'SlateBlue': [ 106, 90, 205 ],
      'SlateGray': [ 112, 128, 144 ],
      'SlateGrey': [ 112, 128, 144 ],
      'SpringGreen': [ 0, 255, 127 ],
      'SteelBlue': [ 70, 130, 180 ],
      'VioletRed': [ 208, 32, 144 ],
      'WhiteSmoke': [ 245, 245, 245 ],
      'YellowGreen': [ 154, 205, 50 ],
      'alice_blue': [ 240, 248, 255 ],
      'ansiBlack': [ 0, 0, 0 ],
      'ansiBlue': [ 0, 80, 250 ],
      'ansiCyan': [ 0, 200, 210 ],
      'ansiGreen': [ 50, 100, 0 ],
      'ansiLightBlack': [ 125, 125, 125 ],
      'ansiLightBlue': [ 0, 125, 250 ],
      'ansiLightCyan': [ 0, 240, 250 ],
      'ansiLightGreen': [ 120, 240, 0 ],
      'ansiLightMagenta': [ 250, 0, 225 ],
      'ansiLightRed': [ 250, 0, 60 ],
      'ansiLightWhite': [ 250, 250, 250 ],
      'ansiLightYellow': [ 240, 250, 0 ],
      'ansiMagenta': [ 200, 0, 180 ],
      'ansiRed': [ 220, 0, 20 ],
      'ansiWhite': [ 200, 200, 200 ],
      'ansiYellow': [ 210, 220, 0 ],
      'ansi_000': [ 0, 0, 0 ],
      'ansi_001': [ 220, 0, 20 ],
      'ansi_002': [ 50, 100, 0 ],
      'ansi_003': [ 210, 220, 0 ],
      'ansi_004': [ 0, 80, 250 ],
      'ansi_005': [ 200, 0, 180 ],
      'ansi_006': [ 0, 200, 210 ],
      'ansi_007': [ 200, 200, 200 ],
      'ansi_008': [ 125, 125, 125 ],
      'ansi_009': [ 250, 0, 60 ],
      'ansi_010': [ 120, 240, 0 ],
      'ansi_011': [ 240, 250, 0 ],
      'ansi_012': [ 0, 125, 250 ],
      'ansi_013': [ 250, 0, 225 ],
      'ansi_014': [ 0, 240, 250 ],
      'ansi_015': [ 250, 250, 250 ],
      'ansi_016': [ 0, 0, 0 ],
      'ansi_017': [ 0, 0, 95 ],
      'ansi_018': [ 0, 0, 135 ],
      'ansi_019': [ 0, 0, 175 ],
      'ansi_020': [ 0, 0, 215 ],
      'ansi_021': [ 0, 0, 255 ],
      'ansi_022': [ 0, 95, 0 ],
      'ansi_023': [ 0, 95, 95 ],
      'ansi_024': [ 0, 95, 135 ],
      'ansi_025': [ 0, 95, 175 ],
      'ansi_026': [ 0, 95, 215 ],
      'ansi_027': [ 0, 95, 255 ],
      'ansi_028': [ 0, 135, 0 ],
      'ansi_029': [ 0, 135, 95 ],
      'ansi_030': [ 0, 135, 135 ],
      'ansi_031': [ 0, 135, 175 ],
      'ansi_032': [ 0, 135, 215 ],
      'ansi_033': [ 0, 135, 255 ],
      'ansi_034': [ 0, 175, 0 ],
      'ansi_035': [ 0, 175, 95 ],
      'ansi_036': [ 0, 175, 135 ],
      'ansi_037': [ 0, 175, 175 ],
      'ansi_038': [ 0, 175, 215 ],
      'ansi_039': [ 0, 175, 255 ],
      'ansi_040': [ 0, 215, 0 ],
      'ansi_041': [ 0, 215, 95 ],
      'ansi_042': [ 0, 215, 135 ],
      'ansi_043': [ 0, 215, 175 ],
      'ansi_044': [ 0, 215, 215 ],
      'ansi_045': [ 0, 215, 255 ],
      'ansi_046': [ 0, 255, 0 ],
      'ansi_047': [ 0, 255, 95 ],
      'ansi_048': [ 0, 255, 135 ],
      'ansi_049': [ 0, 255, 175 ],
      'ansi_050': [ 0, 255, 215 ],
      'ansi_051': [ 0, 255, 255 ],
      'ansi_052': [ 95, 0, 0 ],
      'ansi_053': [ 95, 0, 95 ],
      'ansi_054': [ 95, 0, 135 ],
      'ansi_055': [ 95, 0, 175 ],
      'ansi_056': [ 95, 0, 215 ],
      'ansi_057': [ 95, 0, 255 ],
      'ansi_058': [ 95, 95, 0 ],
      'ansi_059': [ 95, 95, 95 ],
      'ansi_060': [ 95, 95, 135 ],
      'ansi_061': [ 95, 95, 175 ],
      'ansi_062': [ 95, 95, 215 ],
      'ansi_063': [ 95, 95, 255 ],
      'ansi_064': [ 95, 135, 0 ],
      'ansi_065': [ 95, 135, 95 ],
      'ansi_066': [ 95, 135, 135 ],
      'ansi_067': [ 95, 135, 175 ],
      'ansi_068': [ 95, 135, 215 ],
      'ansi_069': [ 95, 135, 255 ],
      'ansi_070': [ 95, 175, 0 ],
      'ansi_071': [ 95, 175, 95 ],
      'ansi_072': [ 95, 175, 135 ],
      'ansi_073': [ 95, 175, 175 ],
      'ansi_074': [ 95, 175, 215 ],
      'ansi_075': [ 95, 175, 255 ],
      'ansi_076': [ 95, 215, 0 ],
      'ansi_077': [ 95, 215, 95 ],
      'ansi_078': [ 95, 215, 135 ],
      'ansi_079': [ 95, 215, 175 ],
      'ansi_080': [ 95, 215, 215 ],
      'ansi_081': [ 95, 215, 255 ],
      'ansi_082': [ 95, 255, 0 ],
      'ansi_083': [ 95, 255, 95 ],
      'ansi_084': [ 95, 255, 135 ],
      'ansi_085': [ 95, 255, 175 ],
      'ansi_086': [ 95, 255, 215 ],
      'ansi_087': [ 95, 255, 255 ],
      'ansi_088': [ 135, 0, 0 ],
      'ansi_089': [ 135, 0, 95 ],
      'ansi_090': [ 135, 0, 135 ],
      'ansi_091': [ 135, 0, 175 ],
      'ansi_092': [ 135, 0, 215 ],
      'ansi_093': [ 135, 0, 255 ],
      'ansi_094': [ 135, 95, 0 ],
      'ansi_095': [ 135, 95, 95 ],
      'ansi_096': [ 135, 95, 135 ],
      'ansi_097': [ 135, 95, 175 ],
      'ansi_098': [ 135, 95, 215 ],
      'ansi_099': [ 135, 95, 255 ],
      'ansi_100': [ 135, 135, 0 ],
      'ansi_101': [ 135, 135, 95 ],
      'ansi_102': [ 135, 135, 135 ],
      'ansi_103': [ 135, 135, 175 ],
      'ansi_104': [ 135, 135, 215 ],
      'ansi_105': [ 135, 135, 255 ],
      'ansi_106': [ 135, 175, 0 ],
      'ansi_107': [ 135, 175, 95 ],
      'ansi_108': [ 135, 175, 135 ],
      'ansi_109': [ 135, 175, 175 ],
      'ansi_110': [ 135, 175, 215 ],
      'ansi_111': [ 135, 175, 255 ],
      'ansi_112': [ 135, 215, 0 ],
      'ansi_113': [ 135, 215, 95 ],
      'ansi_114': [ 135, 215, 135 ],
      'ansi_115': [ 135, 215, 175 ],
      'ansi_116': [ 135, 215, 215 ],
      'ansi_117': [ 135, 215, 255 ],
      'ansi_118': [ 135, 255, 0 ],
      'ansi_119': [ 135, 255, 95 ],
      'ansi_120': [ 135, 255, 135 ],
      'ansi_121': [ 135, 255, 175 ],
      'ansi_122': [ 135, 255, 215 ],
      'ansi_123': [ 135, 255, 255 ],
      'ansi_124': [ 175, 0, 0 ],
      'ansi_125': [ 175, 0, 95 ],
      'ansi_126': [ 175, 0, 135 ],
      'ansi_127': [ 175, 0, 175 ],
      'ansi_128': [ 175, 0, 215 ],
      'ansi_129': [ 175, 0, 255 ],
      'ansi_130': [ 175, 95, 0 ],
      'ansi_131': [ 175, 95, 95 ],
      'ansi_132': [ 175, 95, 135 ],
      'ansi_133': [ 175, 95, 175 ],
      'ansi_134': [ 175, 95, 215 ],
      'ansi_135': [ 175, 95, 255 ],
      'ansi_136': [ 175, 135, 0 ],
      'ansi_137': [ 175, 135, 95 ],
      'ansi_138': [ 175, 135, 135 ],
      'ansi_139': [ 175, 135, 175 ],
      'ansi_140': [ 175, 135, 215 ],
      'ansi_141': [ 175, 135, 255 ],
      'ansi_142': [ 175, 175, 0 ],
      'ansi_143': [ 175, 175, 95 ],
      'ansi_144': [ 175, 175, 135 ],
      'ansi_145': [ 175, 175, 175 ],
      'ansi_146': [ 175, 175, 215 ],
      'ansi_147': [ 175, 175, 255 ],
      'ansi_148': [ 175, 215, 0 ],
      'ansi_149': [ 175, 215, 95 ],
      'ansi_150': [ 175, 215, 135 ],
      'ansi_151': [ 175, 215, 175 ],
      'ansi_152': [ 175, 215, 215 ],
      'ansi_153': [ 175, 215, 255 ],
      'ansi_154': [ 175, 255, 0 ],
      'ansi_155': [ 175, 255, 95 ],
      'ansi_156': [ 175, 255, 135 ],
      'ansi_157': [ 175, 255, 175 ],
      'ansi_158': [ 175, 255, 215 ],
      'ansi_159': [ 175, 255, 255 ],
      'ansi_160': [ 215, 0, 0 ],
      'ansi_161': [ 215, 0, 95 ],
      'ansi_162': [ 215, 0, 135 ],
      'ansi_163': [ 215, 0, 175 ],
      'ansi_164': [ 215, 0, 215 ],
      'ansi_165': [ 215, 0, 255 ],
      'ansi_166': [ 215, 95, 0 ],
      'ansi_167': [ 215, 95, 95 ],
      'ansi_168': [ 215, 95, 135 ],
      'ansi_169': [ 215, 95, 175 ],
      'ansi_170': [ 215, 95, 215 ],
      'ansi_171': [ 215, 95, 255 ],
      'ansi_172': [ 215, 135, 0 ],
      'ansi_173': [ 215, 135, 95 ],
      'ansi_174': [ 215, 135, 135 ],
      'ansi_175': [ 215, 135, 175 ],
      'ansi_176': [ 215, 135, 215 ],
      'ansi_177': [ 215, 135, 255 ],
      'ansi_178': [ 215, 175, 0 ],
      'ansi_179': [ 215, 175, 95 ],
      'ansi_180': [ 215, 175, 135 ],
      'ansi_181': [ 215, 175, 175 ],
      'ansi_182': [ 215, 175, 215 ],
      'ansi_183': [ 215, 175, 255 ],
      'ansi_184': [ 215, 215, 0 ],
      'ansi_185': [ 215, 215, 95 ],
      'ansi_186': [ 215, 215, 135 ],
      'ansi_187': [ 215, 215, 175 ],
      'ansi_188': [ 215, 215, 215 ],
      'ansi_189': [ 215, 215, 255 ],
      'ansi_190': [ 215, 255, 0 ],
      'ansi_191': [ 215, 255, 95 ],
      'ansi_192': [ 215, 255, 135 ],
      'ansi_193': [ 215, 255, 175 ],
      'ansi_194': [ 215, 255, 215 ],
      'ansi_195': [ 215, 255, 255 ],
      'ansi_196': [ 255, 0, 0 ],
      'ansi_197': [ 255, 0, 95 ],
      'ansi_198': [ 255, 0, 135 ],
      'ansi_199': [ 255, 0, 175 ],
      'ansi_200': [ 255, 0, 215 ],
      'ansi_201': [ 255, 0, 255 ],
      'ansi_202': [ 255, 95, 0 ],
      'ansi_203': [ 255, 95, 95 ],
      'ansi_204': [ 255, 95, 135 ],
      'ansi_205': [ 255, 95, 175 ],
      'ansi_206': [ 255, 95, 215 ],
      'ansi_207': [ 255, 95, 255 ],
      'ansi_208': [ 255, 135, 0 ],
      'ansi_209': [ 255, 135, 95 ],
      'ansi_210': [ 255, 135, 135 ],
      'ansi_211': [ 255, 135, 175 ],
      'ansi_212': [ 255, 135, 215 ],
      'ansi_213': [ 255, 135, 255 ],
      'ansi_214': [ 255, 175, 0 ],
      'ansi_215': [ 255, 175, 95 ],
      'ansi_216': [ 255, 175, 135 ],
      'ansi_217': [ 255, 175, 175 ],
      'ansi_218': [ 255, 175, 215 ],
      'ansi_219': [ 255, 175, 255 ],
      'ansi_220': [ 255, 215, 0 ],
      'ansi_221': [ 255, 215, 95 ],
      'ansi_222': [ 255, 215, 135 ],
      'ansi_223': [ 255, 215, 175 ],
      'ansi_224': [ 255, 215, 215 ],
      'ansi_225': [ 255, 215, 255 ],
      'ansi_226': [ 255, 255, 0 ],
      'ansi_227': [ 255, 255, 95 ],
      'ansi_228': [ 255, 255, 135 ],
      'ansi_229': [ 255, 255, 175 ],
      'ansi_230': [ 255, 255, 215 ],
      'ansi_231': [ 255, 255, 255 ],
      'ansi_232': [ 8, 8, 8 ],
      'ansi_233': [ 18, 18, 18 ],
      'ansi_234': [ 28, 28, 28 ],
      'ansi_235': [ 38, 38, 38 ],
      'ansi_236': [ 48, 48, 48 ],
      'ansi_237': [ 58, 58, 58 ],
      'ansi_238': [ 68, 68, 68 ],
      'ansi_239': [ 78, 78, 78 ],
      'ansi_240': [ 88, 88, 88 ],
      'ansi_241': [ 98, 98, 98 ],
      'ansi_242': [ 108, 108, 108 ],
      'ansi_243': [ 118, 118, 118 ],
      'ansi_244': [ 128, 128, 128 ],
      'ansi_245': [ 138, 138, 138 ],
      'ansi_246': [ 148, 148, 148 ],
      'ansi_247': [ 158, 158, 158 ],
      'ansi_248': [ 168, 168, 168 ],
      'ansi_249': [ 178, 178, 178 ],
      'ansi_250': [ 188, 188, 188 ],
      'ansi_251': [ 198, 198, 198 ],
      'ansi_252': [ 208, 208, 208 ],
      'ansi_253': [ 218, 218, 218 ],
      'ansi_254': [ 228, 228, 228 ],
      'ansi_255': [ 238, 238, 238 ],
      'ansi_black': [ 0, 0, 0 ],
      'ansi_blue': [ 0, 80, 250 ],
      'ansi_cyan': [ 0, 200, 210 ],
      'ansi_green': [ 50, 100, 0 ],
      'ansi_light_black': [ 125, 125, 125 ],
      'ansi_light_blue': [ 0, 125, 250 ],
      'ansi_light_cyan': [ 0, 240, 250 ],
      'ansi_light_green': [ 120, 240, 0 ],
      'ansi_light_magenta': [ 250, 0, 225 ],
      'ansi_light_red': [ 250, 0, 60 ],
      'ansi_light_white': [ 250, 250, 250 ],
      'ansi_light_yellow': [ 240, 250, 0 ],
      'ansi_magenta': [ 200, 0, 180 ],
      'ansi_red': [ 220, 0, 20 ],
      'ansi_white': [ 200, 200, 200 ],
      'ansi_yellow': [ 210, 220, 0 ],
      'antique_white': [ 250, 235, 215 ],
      'aquamarine': [ 127, 255, 212 ],
      'azure': [ 240, 255, 255 ],
      'beige': [ 245, 245, 220 ],
      'bisque': [ 255, 228, 196 ],
      'black': [ 0, 0, 0 ],
      'blanched_almond': [ 255, 235, 205 ],
      'blue': [ 0, 0, 255 ],
      'blue_violet': [ 138, 43, 226 ],
      'brown': [ 165, 42, 42 ],
      'burlywood': [ 222, 184, 135 ],
      'cadet_blue': [ 95, 158, 160 ],
      'chartreuse': [ 127, 255, 0 ],
      'chocolate': [ 210, 105, 30 ],
      'coral': [ 255, 127, 80 ],
      'cornflower_blue': [ 100, 149, 237 ],
      'cornsilk': [ 255, 248, 220 ],
      'cyan': [ 0, 255, 255 ],
      'dark_goldenrod': [ 184, 134, 11 ],
      'dark_green': [ 0, 100, 0 ],
      'dark_khaki': [ 189, 183, 107 ],
      'dark_olive_green': [ 85, 107, 47 ],
      'dark_orange': [ 255, 140, 0 ],
      'dark_orchid': [ 153, 50, 204 ],
      'dark_salmon': [ 233, 150, 122 ],
      'dark_sea_green': [ 143, 188, 143 ],
      'dark_slate_blue': [ 72, 61, 139 ],
      'dark_slate_gray': [ 47, 79, 79 ],
      'dark_slate_grey': [ 47, 79, 79 ],
      'dark_turquoise': [ 0, 206, 209 ],
      'dark_violet': [ 148, 0, 211 ],
      'deep_pink': [ 255, 20, 147 ],
      'deep_sky_blue': [ 0, 191, 255 ],
      'dim_gray': [ 105, 105, 105 ],
      'dim_grey': [ 105, 105, 105 ],
      'dodger_blue': [ 30, 144, 255 ],
      'firebrick': [ 178, 34, 34 ],
      'floral_white': [ 255, 250, 240 ],
      'forest_green': [ 34, 139, 34 ],
      'gainsboro': [ 220, 220, 220 ],
      'ghost_white': [ 248, 248, 255 ],
      'gold': [ 255, 215, 0 ],
      'goldenrod': [ 218, 165, 32 ],
      'gray': [ 190, 190, 190 ],
      'green': [ 0, 255, 0 ],
      'green_yellow': [ 173, 255, 47 ],
      'grey': [ 190, 190, 190 ],
      'honeydew': [ 240, 255, 240 ],
      'hot_pink': [ 255, 105, 180 ],
      'indian_red': [ 205, 92, 92 ],
      'ivory': [ 255, 255, 240 ],
      'khaki': [ 240, 230, 140 ],
      'lavender': [ 230, 230, 250 ],
      'lavender_blush': [ 255, 240, 245 ],
      'lawn_green': [ 124, 252, 0 ],
      'lemon_chiffon': [ 255, 250, 205 ],
      'light_blue': [ 173, 216, 230 ],
      'light_coral': [ 240, 128, 128 ],
      'light_cyan': [ 224, 255, 255 ],
      'light_goldenrod': [ 238, 221, 130 ],
      'light_goldenrod_yellow': [ 250, 250, 210 ],
      'light_gray': [ 211, 211, 211 ],
      'light_grey': [ 211, 211, 211 ],
      'light_pink': [ 255, 182, 193 ],
      'light_salmon': [ 255, 160, 122 ],
      'light_sea_green': [ 32, 178, 170 ],
      'light_sky_blue': [ 135, 206, 250 ],
      'light_slate_blue': [ 132, 112, 255 ],
      'light_slate_gray': [ 119, 136, 153 ],
      'light_slate_grey': [ 119, 136, 153 ],
      'light_steel_blue': [ 176, 196, 222 ],
      'light_yellow': [ 255, 255, 224 ],
      'lime_green': [ 50, 205, 50 ],
      'linen': [ 250, 240, 230 ],
      'magenta': [ 255, 0, 255 ],
      'maroon': [ 176, 48, 96 ],
      'medium_aquamarine': [ 102, 205, 170 ],
      'medium_blue': [ 0, 0, 205 ],
      'medium_orchid': [ 186, 85, 211 ],
      'medium_purple': [ 147, 112, 219 ],
      'medium_sea_green': [ 60, 179, 113 ],
      'medium_slate_blue': [ 123, 104, 238 ],
      'medium_spring_green': [ 0, 250, 154 ],
      'medium_turquoise': [ 72, 209, 204 ],
      'medium_violet_red': [ 199, 21, 133 ],
      'midnight_blue': [ 25, 25, 112 ],
      'mint_cream': [ 245, 255, 250 ],
      'misty_rose': [ 255, 228, 225 ],
      'moccasin': [ 255, 228, 181 ],
      'navajo_white': [ 255, 222, 173 ],
      'navy': [ 0, 0, 128 ],
      'navy_blue': [ 0, 0, 128 ],
      'old_lace': [ 253, 245, 230 ],
      'olive_drab': [ 107, 142, 35 ],
      'orange': [ 255, 165, 0 ],
      'orange_red': [ 255, 69, 0 ],
      'orchid': [ 218, 112, 214 ],
      'pale_goldenrod': [ 238, 232, 170 ],
      'pale_green': [ 152, 251, 152 ],
      'pale_turquoise': [ 175, 238, 238 ],
      'pale_violet_red': [ 219, 112, 147 ],
      'papaya_whip': [ 255, 239, 213 ],
      'peach_puff': [ 255, 218, 185 ],
      'peru': [ 205, 133, 63 ],
      'pink': [ 255, 192, 203 ],
      'plum': [ 221, 160, 221 ],
      'powder_blue': [ 176, 224, 230 ],
      'purple': [ 160, 32, 240 ],
      'red': [ 255, 0, 0 ],
      'rosy_brown': [ 188, 143, 143 ],
      'royal_blue': [ 65, 105, 225 ],
      'saddle_brown': [ 139, 69, 19 ],
      'salmon': [ 250, 128, 114 ],
      'sandy_brown': [ 244, 164, 96 ],
      'sea_green': [ 46, 139, 87 ],
      'seashell': [ 255, 245, 238 ],
      'sienna': [ 160, 82, 45 ],
      'sky_blue': [ 135, 206, 235 ],
      'slate_blue': [ 106, 90, 205 ],
      'slate_gray': [ 112, 128, 144 ],
      'slate_grey': [ 112, 128, 144 ],
      'snow': [ 255, 250, 250 ],
      'spring_green': [ 0, 255, 127 ],
      'steel_blue': [ 70, 130, 180 ],
      'tan': [ 210, 180, 140 ],
      'thistle': [ 216, 191, 216 ],
      'tomato': [ 255, 99, 71 ],
      'transparent': [ 255, 255, 255, 0 ],
      'turquoise': [ 64, 224, 208 ],
      'violet': [ 238, 130, 238 ],
      'violet_red': [ 208, 32, 144 ],
      'wheat': [ 245, 222, 179 ],
      'white': [ 255, 255, 255 ],
      'white_smoke': [ 245, 245, 245 ],
      'yellow': [ 255, 255, 0 ],
      'yellow_green': [ 154, 205, 50 ],
    }
    directory = 'C:/Dev/mud/mudlet/'
    color_names = [re.escape(color) for color in color_table.keys()]
    pattern = re.compile(r'<(' + '|'.join(color_names) + ')>')
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file == 'deprecated.lua' or file == 'gizmudlet.lua':  # Skip the file if its name is 'deprecated.lua'
                continue
            if file.endswith('.lua'):
                file_path = os.path.join(root, file)
                with open(file_path, 'r', encoding='utf-8') as lua_file:
                    line_number = 0
                    for line in lua_file:
                        line_number += 1
                        if pattern.search(line):
                            print(f"{file}, Line {line_number}: {line.strip()}")

search_for_colors()