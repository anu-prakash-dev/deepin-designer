using Layouts;

namespace Layouts {
    public class PentagonLayout : ShapeLayout {
        public override void update_track(Gtk.Widget widget, int drag_start_x, int drag_start_y, int? drag_x, int? drag_y) {
            update_size(drag_start_x, drag_start_y, drag_x, drag_y);
                
            clean_draw_dots();
                
            if (width > 0 && height > 0) {
                var star_number = 5;
                var star_points = star_number * 2 + 1;
                var alpha = (2 * Math.PI) / (star_number * 2); 
                var radius = int.min(width, height) / 2;
                var scale = int.max(width, height) / int.min(width, height);
                    
                for (var i = star_points; i != 0; i--) {
                    if (i % 2 != 0) {
                        var r = radius * (i % 2 + 1) / 2;
                        var omega = alpha * i;
                        if (width > height) {
                            add_draw_dot((int) (r * Math.sin(omega) * scale) + (x + width / 2), (int) (r * Math.cos(omega)) + (y + height / 2));
                        } else {
                            add_draw_dot((int) (r * Math.sin(omega)) + (x + width / 2), (int) (r * Math.cos(omega) * scale) + (y + height / 2));
                        }
                    }
                }
            }
        }
    }
}

