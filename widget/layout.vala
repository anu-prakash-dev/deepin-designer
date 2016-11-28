using Gee;
using Gtk;

namespace Layouts {
    public class DrawDot {
        public int x;
        public int y;
        public double? radius;
        public double? start_angle;
        public double? end_angle;

        public DrawDot(int dot_x, int dot_y, double? r=null, double? sa=null, double? ea=null) {
            x = dot_x;
            y = dot_y;
            radius = r;
            start_angle = sa;
            end_angle = ea;
        }
    }

    public abstract class Layout : Object {
        public Gdk.RGBA drag_dot_background_color;
        public Gdk.RGBA drag_dot_frame_color;
        public bool can_draw = false;
        public bool is_create_finish = false;
        public int drag_dot_size = 6;
        public int height;
        public int width;
        public int x;
        public int y;
        public string type = "";
        
        public Layout() {
            drag_dot_frame_color = Utils.hex_to_rgba("#000000", 0.5);
            drag_dot_background_color = Utils.hex_to_rgba("#333333", 0.1);
        }
        
        public abstract void draw_layout(Cairo.Context cr);
        public abstract void update_track(Gtk.Widget widget, int drag_start_x, int drag_start_y, int? drag_x, int? drag_y);
        
        public void draw_drag_frame(Cairo.Context cr) {
            if (can_draw) {
                // Draw frame.
                Utils.set_context_color(cr, drag_dot_frame_color);
                Draw.draw_rectangle(cr, x, y, width, height, false);
                
                // Top left drag dot.
                draw_drag_dot(cr, x - drag_dot_size / 2, y - drag_dot_size / 2);

                // Top middle drag dot.
                draw_drag_dot(cr, x + width / 2 - drag_dot_size / 2, y - drag_dot_size / 2);

                // Top right drag dot.
                draw_drag_dot(cr, x + width - drag_dot_size / 2, y - drag_dot_size / 2);

                // Bottom left drag dot.
                draw_drag_dot(cr, x - drag_dot_size / 2, y + height - drag_dot_size / 2);

                // Bottom middle drag dot.
                draw_drag_dot(cr, x + width / 2 - drag_dot_size / 2, y + height - drag_dot_size / 2);

                // Bottom right drag dot.
                draw_drag_dot(cr, x + width - drag_dot_size / 2, y + height - drag_dot_size / 2);

                // Left drag dot.
                draw_drag_dot(cr, x - drag_dot_size / 2, y + height / 2 - drag_dot_size / 2);

                // Right drag dot.
                draw_drag_dot(cr, x + width - drag_dot_size / 2, y + height / 2 - drag_dot_size / 2);
            }
        }

        public void draw_drag_dot(Cairo.Context cr, int x, int y) {
            Utils.set_context_color(cr, drag_dot_background_color);
            Draw.draw_rectangle(cr, x + 1, y + 1, drag_dot_size - 2, drag_dot_size - 2);

            Utils.set_context_color(cr, drag_dot_frame_color);
            Draw.draw_rectangle(cr, x, y, drag_dot_size, drag_dot_size, false);
        }
    }

    public class ShapeLayout : Layout {
        public Gdk.RGBA frame_color;
        public Gdk.RGBA background_color;
        public ArrayList<DrawDot> draw_dots;
        
        public int? move_save_x;
        public int? move_save_y;
        public ArrayList<DrawDot>? move_save_draw_dots;

        public ShapeLayout() {
            background_color = Utils.hex_to_rgba("#303030", 0.1);
            frame_color = Utils.hex_to_rgba("#ff0000", 0.1);

            draw_dots = new ArrayList<DrawDot>();
        }

        public void add_draw_dot(int x, int y, double? r=null, double? sa=null, double? ea=null) {
            var dot = new DrawDot(x, y, r, sa, ea);
            draw_dots.add(dot);
        }
        
        public void clean_draw_dots() {
            draw_dots = new ArrayList<DrawDot>();
        }
        
        public void save_position() {
            move_save_x = x;
            move_save_y = y;
            move_save_draw_dots = draw_dots;
        }
        
        public void update_position(int offset_x, int offset_y) {
            x = move_save_x + offset_x;
            y = move_save_y + offset_y;
            
            clean_draw_dots();
            foreach (DrawDot dot in move_save_draw_dots) {
                add_draw_dot(dot.x + offset_x,
                             dot.y + offset_y,
                             dot.radius,
                             dot.start_angle,
                             dot.end_angle);
            }
        }
        
        public void clean_move_save_data() {
            move_save_x = null;
            move_save_y = null;
            move_save_draw_dots = null;
        }
        
        public void update_size(int drag_start_x, int drag_start_y, int drag_x, int drag_y) {
            int draw_x = int.min(drag_start_x, drag_x);
            int draw_y = int.min(drag_start_y, drag_y);
            int draw_width = (int) Math.fabs(drag_start_x - drag_x);
            int draw_height = (int) Math.fabs(drag_start_y - drag_y);
            
            can_draw = true;
            
            x = draw_x;
            y = draw_y;
            width = draw_width;
            height = draw_height;
        }
        
        public override void draw_layout(Cairo.Context cr) {
            if (can_draw) {
                if (draw_dots.size > 1) {
                    var first_draw_dot = draw_dots[0];
                    var rest_draw_dots = draw_dots[1:draw_dots.size];

                    if (is_create_finish) {
                        Utils.set_context_color(cr, background_color);
                        if (first_draw_dot.radius != null) {
                            cr.arc(first_draw_dot.x, first_draw_dot.y, first_draw_dot.radius, first_draw_dot.start_angle, first_draw_dot.end_angle);
                        } else {
                            cr.move_to(first_draw_dot.x, first_draw_dot.y);
                        }
                        
                        foreach (var draw_dot in rest_draw_dots) {
                            if (draw_dot.radius != null) {
                                cr.arc(draw_dot.x, draw_dot.y, draw_dot.radius, draw_dot.start_angle, draw_dot.end_angle);
                            } else {
                                cr.line_to(draw_dot.x, draw_dot.y);
                            }
                        }
                        cr.close_path();
                        cr.fill();
                    }
                
                    Utils.set_context_color(cr, frame_color);
                    if (first_draw_dot.radius != null) {
                        cr.arc(first_draw_dot.x, first_draw_dot.y, first_draw_dot.radius, first_draw_dot.start_angle, first_draw_dot.end_angle);
                    } else {
                        cr.move_to(first_draw_dot.x, first_draw_dot.y);
                    }
                    foreach (var draw_dot in rest_draw_dots) {
                        if (draw_dot.radius != null) {
                            cr.arc(draw_dot.x, draw_dot.y, draw_dot.radius, draw_dot.start_angle, draw_dot.end_angle);
                        } else {
                            cr.line_to(draw_dot.x, draw_dot.y);
                        }
                    }
                    cr.close_path();
                    cr.stroke();
                }
            }
        }

        public override void update_track(Gtk.Widget widget, int drag_start_x, int drag_start_y, int? drag_x, int? drag_y) {
        }
    }
}