package cachesim

import "core:fmt"
import "core:os"
import "core:sys/windows"

ProcCacheSimInit :: proc "cdecl" ()
CacheSimInit: ProcCacheSimInit
ProcCacheSimStartCapture :: proc "cdecl" () -> bool
CacheSimStartCapture: ProcCacheSimStartCapture
ProcCacheSimEndCapture :: proc "cdecl" (save: bool)
CacheSimEndCapture: ProcCacheSimEndCapture
ProcCacheSimRemoveHandler :: proc "cdecl" ()
CacheSimRemoveHandler: ProcCacheSimRemoveHandler
ProcCacheSimSetThreadCoreMapping :: proc "cdecl" (thread_id: u64, logical_core_id: int)
CacheSimSetThreadCoreMapping: ProcCacheSimSetThreadCoreMapping
ProcCacheSimGetCurrentThreadId :: proc "cdecl" () -> u64
CacheSimGetCurrentThreadId: ProcCacheSimGetCurrentThreadId

init :: proc() -> bool {
	LIBRARY_NAME: cstring : "CacheSim.dll"
	module := windows.LoadLibraryW(windows.L(LIBRARY_NAME))
	CacheSimInit = cast(ProcCacheSimInit)windows.GetProcAddress(module, "CacheSimInit")
	CacheSimStartCapture =
	cast(ProcCacheSimStartCapture)windows.GetProcAddress(module, "CacheSimStartCapture")
	CacheSimEndCapture =
	cast(ProcCacheSimEndCapture)windows.GetProcAddress(module, "CacheSimEndCapture")
	CacheSimRemoveHandler =
	cast(ProcCacheSimRemoveHandler)windows.GetProcAddress(module, "CacheSimRemoveHandler")
	CacheSimSetThreadCoreMapping =
	cast(ProcCacheSimSetThreadCoreMapping)windows.GetProcAddress(
		module,
		"CacheSimSetThreadCoreMapping",
	)
	CacheSimGetCurrentThreadId =
	cast(ProcCacheSimGetCurrentThreadId)windows.GetProcAddress(
		module,
		"CacheSimGetCurrentThreadId",
	)

	if CacheSimInit == nil ||
	   CacheSimStartCapture == nil ||
	   CacheSimEndCapture == nil ||
	   CacheSimRemoveHandler == nil ||
	   CacheSimSetThreadCoreMapping == nil ||
	   CacheSimGetCurrentThreadId == nil {
		fmt.eprintln("CacheSim API mismatch")
		windows.FreeLibrary(module)
		return false
	}

	CacheSimInit()

	return true
}

start :: proc() -> bool {
	return CacheSimStartCapture()
}

end :: proc() {
	CacheSimEndCapture(true)
}

cancel :: proc() {
	CacheSimEndCapture(false)
}

remove_handler :: proc() {
	CacheSimRemoveHandler()
}

set_thread_core_mapping :: proc(thread_id: u64, logical_core: int) {
	CacheSimSetThreadCoreMapping(thread_id, logical_core)
}

get_current_thread_id :: proc() -> u64 {
	return CacheSimGetCurrentThreadId()
}
