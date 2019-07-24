/******************************************************************************
 * processing/word_based_alphabet.cpp
 *
 * Copyright (C) 2017 Florian Kurpicz <florian.kurpicz@tu-dortmund.de>
 *
 * All rights reserved. Published under the BSD-2 license in the LICENSE file.
 ******************************************************************************/

// #define CHECK = 1
// #define PRINT_IDS = 1

#include <cassert>
#include <fstream>
#include <iostream>
#include <unordered_map>
#include <vector>

template <typename AlphabetType, size_t BUFFER_SIZE=1024>
static void WriteWordBased(const std::string& file_name,
  std::ifstream& in_stream,
  const std::unordered_map<std::string, uint64_t>& word_list,
  [[maybe_unused]] const uint64_t nr_words) {

  // Set in_stream to the beginning of the text
  in_stream.clear();
  in_stream.seekg(0, std::ios::beg);

  std::array<AlphabetType, BUFFER_SIZE> buffer;
  std::ofstream out_stream(file_name, std::ios::out | std::ofstream::binary);

  std::cout << "Creating text based on word-based alphabet." << std::endl;
  std::string cur_word;
  size_t words_in_buffer = 0;
  while (in_stream >> cur_word) {
    buffer[words_in_buffer++] =
      static_cast<AlphabetType>(word_list.find(cur_word)->second);

#ifdef PRINT_IDS
    std::cout << cur_word << " gets id " << word_list.find(cur_word)->second
              << std::endl;
#endif // PRINT_IDS

    if (words_in_buffer == BUFFER_SIZE) {
      for (auto character : buffer) {
        out_stream.write(reinterpret_cast<char*>(&character),
                         sizeof(AlphabetType));
      }
      words_in_buffer = 0;
    }
  }
  for (size_t i = 0; i < words_in_buffer; ++i) {
    out_stream.write(reinterpret_cast<char*>(&buffer[i]), sizeof(AlphabetType));
  }
  
  out_stream.close();

#ifdef CHECK
  std::cout << "Checking correctness. Turn of by removing macro." << std::endl;
  std::ifstream test_stream(file_name, std::ios::in | std::ios::binary);
  std::vector<AlphabetType> tmp;
  tmp.reserve(nr_words);
  test_stream.read(reinterpret_cast<char*>(tmp.data()),
    nr_words * sizeof(AlphabetType));
  test_stream.close();

  in_stream.clear();
  in_stream.seekg(0, std::ios::beg);
  size_t cur_pos = 0;
  while (in_stream >> cur_word) {
    if (tmp[cur_pos++] !=
        static_cast<AlphabetType>(word_list.find(cur_word)->second)) {
      std::cout << "Error at position " << cur_pos - 1 << "." << std::endl;
      std::exit(EXIT_FAILURE);
    }
  }
  std::cout << "Test succeeded." << std::endl;
#endif // CHECK
  in_stream.close();
}

int main(int argc, char const *argv[]) {
  if (argc != 3) {
    std::cout << argv[0] << " requires exactly 2 parameter: " << std::endl
              << argv[0] << " [file name] [output name]" << std::endl;
    std::exit(EXIT_FAILURE);
  }

  std::string cur_word;
  std::ifstream stream;
  stream.open(argv[1]);

  std::unordered_map<std::string, uint64_t> word_list;
  uint64_t max_char = 0;
  uint64_t nr_words = 0;

  std::cout << "Reading text word by word." << std::endl;
  while (stream >> cur_word) {
    ++nr_words;
    auto result = word_list.find(cur_word);
    if (result == word_list.end()) {
      word_list.emplace(cur_word, max_char++);
    }
  }
  assert(max_char == word_list.size());
  
  std::cout << "Finished reading. Effective alphabet size is "
            << max_char << std::endl;

  if (max_char < (1ULL << 8)) {
    WriteWordBased<uint8_t>(std::string(argv[2]), stream, word_list, nr_words);
    std::cout << "One character requires 1 byte." << std::endl;
  } else if (max_char < (1ULL << 16)) {
    WriteWordBased<uint16_t>(std::string(argv[2]), stream, word_list, nr_words);
    std::cout << "One character requires 2 bytes." << std::endl;
  } else if (max_char < (1ULL << 32)) {
    WriteWordBased<uint32_t>(std::string(argv[2]), stream, word_list, nr_words);
    std::cout << "One character requires 4 bytes." << std::endl;
  } else if (max_char <= 0xFFFFFFFFFFFFFFFFULL) {
    WriteWordBased<uint64_t>(std::string(argv[2]), stream, word_list, nr_words);
    std::cout << "One character requires 8 bytes." << std::endl;
  }
  stream.close();

  return 0;
}

/******************************************************************************/
