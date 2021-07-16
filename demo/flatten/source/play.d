module play;

import re;
import re.gfx;
import re.gfx.shapes.model;
import re.gfx.shapes.grid;
import re.ng.camera;
import re.math;
static import raylib;
import core.stdc.math : ceil;
import std.stdio;

/// simple 3d demo scene
class PlayScene : Scene3D {
    const int CAPTURE_SHEET_WIDTH = 4;
    const int CAPTURE_FRAMECOUNT = 16;
    // const int CAPTURE_FRAMESKIP = 6; // 0.1 sec

    int start_frame;
    Image[] captured_frames;
    bool saved_capture = false;

    override void on_start() {
        clear_color = Colors.BLACK;

        start_frame = Time.frame_count + 2; // delay

        auto thing = create_entity("thing", Vector3(0, 0, 0));
        auto thing_asset = Core.content.load_model("models/fountain3.glb");
        auto thing_model = thing.add_component(new Model3D(thing_asset));
        thing_model.transform.scale = Vector3(4, 4, 4);
        thing_model.transform.orientation = Vector3(C_PI_2, 0, 0); // euler angles

        // set the camera position
        cam.entity.position = Vector3(10, 12, 10);

        // add a camera to look at the thing
        // cam.entity.add_component(new CameraOrbit(thing, PI * (15.0 / 16)));
        cam.entity.add_component(new CameraOrbit(thing, 0));
        // cam.entity.add_component(new CameraFreeLook(thing));
    }

    override void update() {
        // update camera
        // TODO: controlled spin

        immutable int frame_num = Time.frame_count - start_frame;

        if (frame_num <= -1) {
            // reset while waiting for capture
            // cam.entity.get_component!CameraOrbit().set_xz_angle(0);
            cam.entity.get_component!CameraOrbit()
                .set_xz_angle(0);
            cam.entity.get_component!CameraOrbit().pause = true;
        }

        // writefln("frame num: %s", frame_num);

        if (frame_num > 0) {
            // frame capture
            if (captured_frames.length < CAPTURE_FRAMECOUNT) {
                // if (frame_num % CAPTURE_FRAMESKIP == 0) {
                // capture frame data
                auto frame = raylib.GetScreenData();

                // correct for capture (is upside down??)

                // raylib.ImageFlipVertical(&frame);
                // raylib.ImageFlipHorizontal(&frame);
                writefln("cap: %s (f: %s)", captured_frames.length, frame_num);
                captured_frames ~= frame;

                cam.entity.get_component!CameraOrbit()
                    .set_xz_angle(2 * PI * (captured_frames.length / cast(float) CAPTURE_FRAMECOUNT));
                // }
            } else if (!saved_capture) {
                // done capturing
                auto target = raylib.LoadRenderTexture(cast(int) resolution.x * CAPTURE_SHEET_WIDTH,
                        cast(int) resolution.y * cast(int) ceil(
                            cast(float) CAPTURE_FRAMECOUNT / CAPTURE_SHEET_WIDTH));

                raylib.BeginTextureMode(target);
                raylib.BeginDrawing();

                raylib.ClearBackground(Colors.BLANK);

                for (int i = 0; i < CAPTURE_FRAMECOUNT; i++) {
                    auto tex = raylib.LoadTextureFromImage(captured_frames[i]);
                    raylib.DrawTexture(tex, (i % CAPTURE_SHEET_WIDTH) * cast(int) resolution.x,
                            (i / CAPTURE_SHEET_WIDTH) * cast(int) resolution.y, Colors.WHITE);
                }

                raylib.EndDrawing();
                raylib.EndTextureMode();

                auto target_img = raylib.GetTextureData(target.texture);
                raylib.ImageFlipVertical(&target_img);
                raylib.ExportImage(target_img, "captures.png");

                // TODO: unload everything

                saved_capture = true;
                // Core.exit();
            }
        }

        if (Input.is_mouse_pressed(MouseButton.MOUSE_LEFT_BUTTON)) {
            if (Input.is_cursor_locked) {
                Input.unlock_cursor();
            } else {
                Input.lock_cursor();
            }
        }

        super.update();
    }
}