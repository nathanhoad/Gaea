@tool
class_name GaeaGenerator
extends Node2D
## Base class for the Gaea addon's procedural generator.


signal generation_finished

const NEIGHBORS := [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN,
					Vector2(1, 1), Vector2(1, -1), Vector2(-1, -1), Vector2(-1, 1)]

## If [code]true[/code], allows for generating a preview of the generation
## in the editor. Useful for debugging.
@export var preview: bool = false :
	set(value):
		preview = value
		if value == false:
			erase()
@export var tile_map: TileMap
## If [code]true[/code] regenerates on [code]_ready()[/code].
## If [code]false[/code] and a world was generated in the editor,
## it will be kept.
@export var regenerate_on_ready: bool = true
## If [code]false[/code], the tilemap will not be cleared when generating.
@export var clear_tilemap_on_generation: bool = true

var tile_size : Vector2
var grid : Dictionary


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	tile_size = tile_map.tile_set.tile_size

	if regenerate_on_ready:
		generate()


func generate() -> void:
	if not is_instance_valid(tile_map):
		push_error("%s doesn't have a TileMap" % name)
		return


func erase(clear_tilemap := true) -> void:
	if clear_tilemap:
		tile_map.clear()
	grid.clear()


### Utils ###


func get_tile(pos: Vector2) -> TileInfo:
	return grid[pos]


func map_to_world(tile: Vector2) -> Vector2:
	return tile * tile_size + tile_size / 2


static func are_all_neighbors_of_type(grid: Dictionary, pos: Vector2, type: TileInfo) -> bool:
	for neighbor in NEIGHBORS:
		if not grid.has(pos + neighbor):
			continue

		if grid[pos + neighbor] != type:
			return false

	return true


static func get_neighbor_count_of_type(grid: Dictionary, pos: Vector2, type: TileInfo) -> int:
	var count = 0

	for neighbor in NEIGHBORS:
		if not grid.has(pos + neighbor):
			if type == null:
				count += 1
			continue

		if grid[pos + neighbor] == type:
			count += 1

	return count


static func get_tiles_of_type(type: TileInfo, grid: Dictionary) -> Array[Vector2i]:
	var tiles: Array[Vector2i] = []
	for tile in grid:
		if grid[tile] == type:
			tiles.append(tile)

	return tiles


### Steps ###

func _draw_tiles() -> void:
	for tile in grid:
		var tile_info = grid[tile]
		if not (tile_info is TileInfo):
			continue

		match tile_info.type:
			TileInfo.Type.SINGLE_CELL:
				tile_map.set_cell(
					tile_info.layer, tile, tile_info.source_id,
					tile_info.atlas_coord, tile_info.alternative_tile
				)
			TileInfo.Type.TERRAIN:
				tile_map.set_cells_terrain_connect(
					tile_info.layer, [tile],
					tile_info.terrain_set, tile_info.terrain
				)


func _apply_modifiers(modifiers: Array[Modifier]) -> void:
	for modifier in modifiers:
		if not (modifier is Modifier):
			continue

		grid = modifier.apply(grid, self)


### Editor ###


func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray

	if not is_instance_valid(tile_map):
		warnings.append("TileMap is required to generate.")

	return warnings
