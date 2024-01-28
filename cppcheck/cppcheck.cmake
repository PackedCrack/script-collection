add_custom_target(YOUR_TARGET
    COMMAND ./cppcheck.sh
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
    COMMENT "Running CppCheck.."
    VERBATIM
)
