# needed because cppcheck outputs contents to stderr, but we need to redirect to a file

if [[ "$1" == "XML" || "$1" == "xml" ]]; then
	XML_ARGS='--xml --xml-version=2'
	XML_REDIRECT="2>${MESON_BUILD_ROOT}/cppcheck.xml"
else
	XML_ARGS=
	XML_REDIRECT=
fi

MESON_SOURCE_ROOT=${MESON_SOURCE_ROOT:-./}
MESON_BUILD_ROOT=${MESON_BUILD_ROOT:-buildresults}

eval cppcheck --quiet --enable=style --force ${XML_ARGS} \
	-I ${MESON_CURRENT_SOURCE_ROOT}/include \
	${MESON_SOURCE_ROOT}/src ${MESON_SOURCE_ROOT}/test \
	${XML_REDIRECT}
