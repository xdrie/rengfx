module re.ng.scene2d;

static import raylib;
import re;
import std.string;
import re.ecs;
import re.math;

/// represents a scene rendered in 2d
abstract class Scene2D : Scene {
    override void render_scene() {
        // render 2d components
        foreach (component; ecs.storage.renderable_components) {
            auto renderable = cast(Renderable2D) component;
            assert(renderable !is null, "renderable was not 2d");
            renderable.render();
            if (Core.debug_render) {
                renderable.debug_render();
            }
        }
    }
}