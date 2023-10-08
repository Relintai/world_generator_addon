# World Generator

An addon for the Pandemonium Engine to help with creating pseudo-procedural worlds.

Currently has built in methods to work with both Terraman and Voxelman.

The idea is that we have a World resource, this contains Continents, those zontain Zones, and those contain SubZones.

The position and size is predetermined by the designer. And then when a chunk needs to be generated it gets put into this world, and then these generate it's data.

- World does mostly nothing on it's own for now, except for holding continents.
- Continents handle things like oceans, and big mountains.
- Zones generate proper terrain, and add props. They need to blend into continents.
- SubZones can be used as spawners, prop spawners, or they can even do terrain modifications.

So when a chunk needs to be generated, first the world gets it, then all continents which intersect with it's position,
then all zones which intersect with it's position, then all subzones which intersect with it's position.

Comes with in-editor tools to help with editing these resources.

