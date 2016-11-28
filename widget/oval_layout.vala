using Layouts;

namespace Layouts {
    public class OvalLayout : ShapeLayout {
        public override void draw_layout(Cairo.Context cr) {
            if (can_draw) {
                if (width > 0 && height > 0) {
                    var radius = int.min(width, height) / 2;
                    var scale = int.max(width, height) / int.min(width, height);
                        
                    if (is_create_finish) {
                        Utils.set_context_color(cr, background_color);
                        cr.save();
                        cr.translate(x + width / 2, y + height / 2);
                        if (width > height) {
                            cr.scale(scale, 1);
                        } else {
                            cr.scale(1, scale);
                        }
                        cr.translate(-x - width / 2, -y - height / 2);
                        cr.arc(x + width / 2, y + height / 2, radius, 0, 2 * Math.PI);
                    
                        cr.restore();
                    
                        cr.fill();
                    }
                    
                    Utils.set_context_color(cr, frame_color);
                    cr.save();
                    cr.translate(x + width / 2, y + height / 2);
                    if (width > height) {
                        cr.scale(scale, 1);
                    } else {
                        cr.scale(1, scale);
                    }
                    cr.translate(-x - width / 2, -y - height / 2);
                    cr.arc(x + width / 2, y + height / 2, radius, 0, 2 * Math.PI);
                    
                    cr.restore();
                    
                    cr.set_line_width(1);
                    cr.stroke();
                }
            }            
        }
            
        public override void update_track(Gtk.Widget widget, int drag_start_x, int drag_start_y, int? drag_x, int? drag_y) {
            update_size(drag_start_x, drag_start_y, drag_x, drag_y);
        }        
    }
}