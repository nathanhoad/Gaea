@tool
@icon("walls.svg")
class_name Walls
extends Modifier
## Adds [param wall_tile] below any tile that isn't the Generator's default tile.
## Useful for tilesets whose walls are different tiles from the ceiling.


## The tile to be placed. Will be placed below any tile
## that isn't the Generator's default tile.
@export var wall_tile: TileInfo


func apply(grid: Dictionary, generator: GaeaGenerator) -> Dictionary:
	# Check if the generator has a "settings" variable and if those
	# settings have a "tile" variable.
	if not generator.get("settings") or not generator.settings.get("tile"):
		push_warning("Walls modifier not compatible with %s" % generator.name)
		return grid

	var newGrid := grid.duplicate()
	for tile in grid:
		if grid[tile] == generator.settings.tile:
			var above = tile + Vector2.UP
			if grid.has(above) and grid[above] != generator.settings.tile:
				newGrid[tile] = wall_tile

	return newGrid
