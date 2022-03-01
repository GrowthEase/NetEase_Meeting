#rm -rf output_mac
cmake -H./. -Boutput_mac -G"Xcode"
cmake --build output_mac --config Release
