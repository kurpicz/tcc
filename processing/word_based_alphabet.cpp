/*******************************************************************************
 * processing/word_based_alphabet.cpp
 *
 * Copyright (C) 2017 Florian Kurpicz <florian.kurpicz@tu-dortmund.de>
 *
 * All rights reserved. Published under the BSD-2 license in the LICENSE file.
 ******************************************************************************/

#include <fstream>
#include <iostream>
#include <unordered_map>

int main(int argc, char const *argv[]) {
  if (argc != 3) {
    std::cout << argv[0] << " requires exactly 2 parameter: "
              << argv[0] << " [file name] "
              << "[resulting symbol width in byte]" << std::endl;
    std::exit(EXIT_FAILURE);
  }
  uint32_t byte_width = std::stoi(std::string(argv[2]));
  if (byte_width > 8 || 
    (byte_width != 1 && ((byte_width == 6) || ((byte_width % 2) == 1)))) {
    std::cout << "[resulting symbol width in byte] must be 1, 2, 4 or 8."
              << std::endl;
    std::exit(EXIT_FAILURE);
  }

  std::string cur_word;
  std::ifstream stream;
  stream.open(argv[1]);

  while (stream >> cur_word) {

  }


  return 0;
}

/******************************************************************************/