using Layouts;

namespace Layouts {
    public class PencilLayout : ShapeLayout {
        public override void draw_layout(Cairo.Context cr) {
            if (can_draw) {
                if (is_create_finish) {
                    var first_draw_dot = draw_dots[0];
                    var rest_draw_dots = draw_dots[1:draw_dots.size];
                        
                    Utils.set_context_color(cr, frame_color);
                    cr.move_to(first_draw_dot.x, first_draw_dot.y);
    
                    int counter = 0;
                    int? x1 = null;
                    int? y1 = null;
                    int? x2 = null;
                    int? y2 = null;
                    int? x3 = null;
                    int? y3 = null;
                    foreach (var draw_dot in rest_draw_dots) {
                        if (counter % 6 == 0) {
                            x1 = draw_dot.x;
                            y1 = draw_dot.y;
                        } else if (counter % 6 == 2) {
                            x2 = draw_dot.x;
                            y2 = draw_dot.y;
                        } else if (counter % 6 == 4) {
                            x3 = draw_dot.x;
                            y3 = draw_dot.y;
                                
                            cr.curve_to(x1, y1, x2, y2, x3, y3);
                        }
                        counter++;
                    }
                    cr.stroke();
                } else {
                    var first_draw_dot = draw_dots[0];
                    var rest_draw_dots = draw_dots[1:draw_dots.size];
                        
                    Utils.set_context_color(cr, frame_color);
                    cr.move_to(first_draw_dot.x, first_draw_dot.y);
    
                    foreach (var draw_dot in rest_draw_dots) {
                        cr.line_to(draw_dot.x, draw_dot.y);
                    }
                    cr.stroke();
                }
            }            
        }
    
        public override void update_track(Gtk.Widget widget, int drag_start_x, int drag_start_y, int? drag_x, int? drag_y) {
            update_size(drag_start_x, drag_start_y, drag_x, drag_y);
                
            if (draw_dots.size > 0) {
                int? min_x = null;
                int? max_x = null;
                int? min_y = null;
                int? max_y = null;
    
                foreach (var draw_dot in draw_dots) {
                    if (min_x == null || draw_dot.x < min_x) {
                        min_x = draw_dot.x;
                    }
                        
                    if (max_x == null || draw_dot.x > max_x) {
                        max_x = draw_dot.x;
                    }
                        
                    if (min_y == null || draw_dot.y < min_y) {
                        min_y = draw_dot.y;
                    }
                        
                    if (max_y == null || draw_dot.y > max_y) {
                        max_y = draw_dot.y;
                    }
                }
                    
                x = min_x;
                y = min_y;
                width = max_x - min_x;
                height = max_y - min_y;
            }
                    
            add_draw_dot(drag_x, drag_y);
        }
    }
}
