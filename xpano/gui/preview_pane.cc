#include "gui/preview_pane.h"

#include <imgui.h>
#include <opencv2/core.hpp>
#include <opencv2/imgproc.hpp>
#include <SDL.h>

#include "constants.h"
#include "gui/coord.h"

namespace xpano::gui {

namespace {
[[nodiscard]] float GetAspect(const cv::Mat &image_data) {
  auto width = static_cast<float>(image_data.size[1]);
  auto height = static_cast<float>(image_data.size[0]);
  return width / height;
}
}  // namespace

PreviewPane::PreviewPane(SDL_Renderer *renderer) : renderer_(renderer){};

void PreviewPane::Load(cv::Mat image) {
  if (!tex_) {
    tex_.reset(SDL_CreateTexture(renderer_, SDL_PIXELFORMAT_BGR24,
                                 SDL_TEXTUREACCESS_STATIC, kLoupeSize,
                                 kLoupeSize));
  }

  int larger_dim = image.size[0] > image.size[1] ? 0 : 1;

  cv::Mat resized;
  ImVec2 coord_uv;
  if (image.size[larger_dim] > kLoupeSize) {
    cv::Size size;
    float aspect = GetAspect(image);
    if (aspect >= 1.0f) {
      size = cv::Size(kLoupeSize, static_cast<int>(kLoupeSize / aspect));
      coord_uv = ImVec2(1.0f, 1.0f / aspect);
    } else {
      size = cv::Size(static_cast<int>(kLoupeSize * aspect), kLoupeSize);
      coord_uv = ImVec2(1.0f * aspect, 1.0f);
    }
    cv::resize(image, resized, size, 0, 0, cv::INTER_AREA);
  } else {
    resized = image;
    coord_uv = ImVec2(static_cast<float>(image.size[1]) / kLoupeSize,
                      static_cast<float>(image.size[0]) / kLoupeSize);
  }

  SDL_Rect target{0, 0, resized.size[1], resized.size[0]};
  SDL_UpdateTexture(tex_.get(), &target, resized.data,
                    static_cast<int>(resized.step1()));

  coord_ = Coord{ImVec2(0.0f, 0.0f), coord_uv, 1.0f, 0};
}

void PreviewPane::Draw() {
  ImGui::Begin("Preview");
  if (tex_) {
    ImVec2 available_size = ImGui::GetContentRegionAvail();
    auto p_min = ImGui::GetCursorScreenPos();
    auto p_max = ImVec2(p_min.x + available_size.x, p_min.y + available_size.y);

    float aspect = coord_.uv1.x / coord_.uv1.y;
    if (available_size.x / available_size.y < aspect) {
      auto mid = (p_min.y + p_max.y) / 2.0f;
      auto half_y = available_size.x / aspect / 2.0f;
      p_min.y = mid - half_y;
      p_max.y = mid + half_y;
    } else {
      auto mid = (p_min.x + p_max.x) / 2.0f;
      auto half_x = available_size.y * aspect / 2.0f;
      p_min.x = mid - half_x;
      p_max.x = mid + half_x;
    }

    ImGui::GetWindowDrawList()->AddImage(tex_.get(), p_min, p_max, coord_.uv0,
                                         coord_.uv1);
  }
  ImGui::End();
}

}  // namespace xpano::gui
