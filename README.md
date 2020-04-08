# Godot-WorldStream
A Godot system to create game maps (3D) that load smoothly as the player moves.
This is based on the system originally developed for https://github.com/rokyfox/TerrainTest .

A WIP world editor is icluded.

# Technical details
Terrain data is stored as an image, with elevation and texture being stored in the red and green color chanels respectively (the blue channel is currently unused). Sections of the map are loaded in chunks centered around the player. Chunks have variable mesh resolution, with those nearest the player having higher polygon density. As the player moves, the map updates in real time. This is done in a separate thread to avoid pauses in gameplay. If the player starts to approach the edge of the loaded map, threading is abbandoned (i.e. the game freezes) until the current area is fully loaded.

# TODO
 - Basic editor features (saving, history tree etc.)
 - Editor tools for creating map objects (e.g. buildings, trees)
 - Bridge gaps between chunks of different resolutions
 - Smoother terrain loading (e.g. fade in new chunks)
 - etc
