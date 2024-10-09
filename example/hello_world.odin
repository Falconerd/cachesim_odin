package cachesim_example

import "core:fmt"

import cachesim ".."

main :: proc() {
	assert(cachesim.init())

	cachesim.set_thread_core_mapping(cachesim.get_current_thread_id(), 0)

	cachesim.start()

	fmt.printfln("Hello, world (with cache simulation)!")

	cachesim.end()
}
