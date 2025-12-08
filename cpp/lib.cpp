#include <stdexcept>

extern "C" {
int ThrowOutOfRangeCatchException() {
  try {
    throw std::out_of_range("Test exception");
  } catch (const std::exception &) {
    return 0;
  } catch (...) {
    return 1;
  }
}

int ThrowOutOfRangeCatchOutOfRange() {
  try {
    throw std::out_of_range("Test exception");
  } catch (const std::out_of_range &) {
    return 0;
  } catch (...) {
    return 1;
  }
}

int ThrowLengthErrorCatchException() {
  try {
    throw std::length_error("Test exception");
  } catch (const std::exception &) {
    return 0;
  } catch (...) {
    return 1;
  }
}

int ThrowLengthErrorCatchLengthError() {
  try {
    throw std::length_error("Test exception");
  } catch (const std::length_error &) {
    return 0;
  } catch (...) {
    return 1;
  }
}

int ThrowInvalidArgumentCatchException() {
  try {
    throw std::invalid_argument("Test exception");
  } catch (const std::exception &) {
    return 0;
  } catch (...) {
    return 1;
  }
}

int ThrowRangeErrorCatchException() {
  try {
    throw std::range_error("Test exception");
  } catch (const std::exception &) {
    return 0;
  } catch (...) {
    return 1;
  }
}

int ThrowLogicErrorCatchException() {
  try {
    throw std::logic_error("Test exception");
  } catch (const std::exception &) {
    return 0;
  } catch (...) {
    return 1;
  }
}

int ThrowRuntimeErrorCatchException() {
  try {
    throw std::runtime_error("Test exception");
  } catch (const std::exception &) {
    return 0;
  } catch (...) {
    return 1;
  }
}
}
