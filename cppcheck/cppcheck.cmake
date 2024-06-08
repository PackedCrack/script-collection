if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
	add_custom_target(YOUR_TARGET
		COMMAND PowerShell -ExecutionPolicy Bypass -File cppcheck.ps1
		WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
		COMMENT "Running CppCheck.."
		VERBATIM
	)
else()
	add_custom_target(YOUR_TARGET
		COMMAND /bin/bash cppcheck.sh
		WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
		COMMENT "Running CppCheck.."
		VERBATIM
	)
endif()