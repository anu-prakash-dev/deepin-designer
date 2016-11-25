using Gee;

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

    public class Layout {
        public int x;
        public int y;
        public int width;
        public int height;
        public Gdk.RGBA frame_color;
        public Gdk.RGBA background_color;
        public Gdk.RGBA drag_dot_frame_color;
        public Gdk.RGBA drag_dot_background_color;
        public int drag_dot_size = 6;
        public bool can_draw = false;
        public bool is_create_finish = false;

        public ArrayList<DrawDot> draw_dots;
        public string type = "";

        public Layout() {
            background_color = Utils.hex_to_rgba("#303030", 0.1);
            frame_color = Utils.hex_to_rgba("#ff0000", 0.1);

            drag_dot_frame_color = Utils.hex_to_rgba("#000000", 0.5);
            drag_dot_background_color = Utils.hex_to_rgba("#333333", 0.1);

            draw_dots = new ArrayList<DrawDot>();
        }

        public void draw_layout(Cairo.Context cr) {
            if (can_draw) {
                if (type == "Oval") {
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
                } else if (draw_dots.size > 1) {
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

        public void add_draw_dot(int x, int y, double? r=null, double? sa=null, double? ea=null) {
            var dot = new DrawDot(x, y, r, sa, ea);
            draw_dots.add(dot);
        }
        
        public void clean_draw_dots() {
            draw_dots = new ArrayList<DrawDot>();
        }
        
        public void update_track(int draw_x, int draw_y, int draw_width, int draw_height) {
            can_draw = true;
            
            x = draw_x;
            y = draw_y;
            width = draw_width;
            height = draw_height;
            
            clean_draw_dots();

            if (type == "Rectangle") {
                add_draw_dot(x, y);
                add_draw_dot(x + width, y);
                add_draw_dot(x + width, y + height);
                add_draw_dot(x, y + height);
            } else if (type == "Rounded_Rectangle") {
                var r = 4;
        
                add_draw_dot(x + width - r, y + r, r, Math.PI * 3 / 2, Math.PI * 2);
                add_draw_dot(x + width - r, y + height - r, r, 0, Math.PI / 2);
                add_draw_dot(x + r, y + height - r, r, Math.PI / 2, Math.PI);
                add_draw_dot(x + r, y + r, r, Math.PI, Math.PI * 3 / 2);
            } else if (type == "Triangle") {
                add_draw_dot(x + width / 2, y);
                add_draw_dot(x + width, y + height);
                add_draw_dot(x, y + height);
            } else if (type == "Five_Pointed_Star") {
                var star_number = 5;
                var star_points = star_number * 2 + 1;
                var alpha = (2 * Math.PI) / (star_number * 2); 
                var radius = int.min(width, height) / 2;
                var scale = int.max(width, height) / int.min(width, height);
        
                for (var i = star_points; i != 0; i--) {
                    var r = radius * (i % 2 + 1) / 2;
                    var omega = alpha * i;
                    if (width > height) {
                        add_draw_dot((int) (r * Math.sin(omega) * scale) + (x + width / 2), (int) (r * Math.cos(omega)) + (y + height / 2));
                    } else {
                        add_draw_dot((int) (r * Math.sin(omega)) + (x + width / 2), (int) (r * Math.cos(omega) * scale) + (y + height / 2));
                    }
                }
            } else if (type == "Pentagon") {
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
            } else if (type == "Line") {
                add_draw_dot(x, y);
                add_draw_dot(x + width, y + height);
            }
        }
    }
}