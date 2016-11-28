using Layouts;

namespace Layouts {
    public class TriangleLayout : ShapeLayout {
        public override void update_track(Gtk.Widget widget, int drag_start_x, int drag_start_y, int? drag_x, int? drag_y) {
            update_size(drag_start_x, drag_start_y, drag_x, drag_y);
                
            clean_draw_dots();
                
            add_draw_dot(x + width / 2, y);
            add_draw_dot(x + width, y + height);
            add_draw_dot(x, y + height);
        }
    }
}

