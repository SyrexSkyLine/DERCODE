#if MC_VERSION >= 11300 || defined IS_IRIS
	#define TEXTURE_SIZE_AVAILABLE 1
	#define VERY_OLD_MC 0
#else	
	#define TEXTURE_SIZE_AVAILABLE 0
	#define VERY_OLD_MC 1
#endif