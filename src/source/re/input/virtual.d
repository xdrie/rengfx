module re.input.virtual;

import re.input.input;
import std.algorithm;

abstract class InputNode {
    void update();
}

abstract class VirtualInput {
    public InputNode[] nodes;
    public abstract void update();
}

class VirtualButton : VirtualInput {
    abstract class ButtonNode : InputNode {
        @property public bool is_down();
        @property public bool is_up();
        @property public bool is_pressed();
        @property public bool is_released();
    }

    class KeyboardKey : ButtonNode {
        public Keys key;

        this(Keys key) {
            this.key = key;
        }

        @property public override bool is_down() {
            return Input.is_key_down(key);
        }

        @property public override bool is_up() {
            return Input.is_key_up(key);
        }

        @property public override bool is_pressed() {
            return Input.is_key_pressed(key);
        }

        @property public override bool is_released() {
            return Input.is_key_released(key);
        }
    }

    @property public bool is_down() {
        return nodes.any!(x => (cast(ButtonNode) x).is_down);
    }

    @property public bool is_up() {
        return nodes.any!(x => (cast(ButtonNode) x).is_up);
    }

    @property public bool is_pressed() {
        return nodes.any!(x => (cast(ButtonNode) x).is_pressed);
    }

    @property public bool is_released() {
        return nodes.any!(x => (cast(ButtonNode) x).is_released);
    }
}

unittest {
    auto the_button = VirtualButton();
    the_button.nodes ~= VirtualButton.KeyboardKey(Keys.KEY_E);

}