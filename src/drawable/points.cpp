// Copyright 2022 Nathan Prat

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//     http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#include "points.h"

#include <cassert>

namespace interstellar {

namespace drawable {

Point2DInPixels::Point2DInPixels(unsigned int x, unsigned int y) : x(x), y(y) {}

Point2DRelative::Point2DRelative(float x, float y) : x(x), y(y) {
  assert(x >= 0.0f && x <= 1.0f && y >= 0.0f && y <= 1.0f);
}

}  //   namespace drawable

}  // namespace interstellar