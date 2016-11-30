using Layouts;

namespace Layouts {
    public class RoundedRectangleLayout : ShapeLayout {
        public override void update_track(Gtk.Widget widget, int drag_start_x, int drag_start_y, int? drag_x, int? drag_y) {
            update_size(drag_start_x, drag_start_y, drag_x, drag_y);
                
            clean_draw_dots();
                
            var r = 4;
            
            add_draw_rounded_dot(x + width - r, y + r, r, Math.PI * 3 / 2, Math.PI * 2);
            add_draw_rounded_dot(x + width - r, y + height - r, r, 0, Math.PI / 2);
            add_draw_rounded_dot(x + r, y + height - r, r, Math.PI / 2, Math.PI);
            add_draw_rounded_dot(x + r, y + r, r, Math.PI, Math.PI * 3 / 2);
        }
    }
}

