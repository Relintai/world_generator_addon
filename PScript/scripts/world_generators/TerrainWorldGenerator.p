tool;
extends TerrainLevelGenerator;
class_name TerrainWorldGenerator;

# Copyright (c) 2019-2021 Péter Magyar
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

export(int) int _level_seed;
export(bool) bool _spawn_mobs;
export(Resource) Resource world_gen_world = null;

TerrainWorld _world;
TerrainLibrary _library;

void setup(TerrainWorld world, int level_seed, bool spawn_mobs, TerrainLibrary library) {
	_level_seed = level_seed;
	_spawn_mobs = spawn_mobs;
	_library = library;
	
	if world_gen_world != null {
		world_gen_world.setup_terra_library(_library, _level_seed);
		_library.refresh_rects();
	}
}

Vector2 get_spawn_chunk_position() {
	if world_gen_world != null {
		Array spawners = world_gen_world.get_spawn_positions();
		
		if spawners.size() > 0 {
			Vector2 v = spawners[0][1];
			return v;
		}
	}
	
	return Vector2();
}

void _generate_chunk(TerrainChunk chunk) {
	if world_gen_world == null {
		return;
	}
	
	world_gen_world.generate_terra_chunk(chunk, _level_seed, _spawn_mobs);
}
