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
            if (type == "Oval") {
                var radius = int.min(width, height) / 2;
                var scale = int.max(width, height) / int.min(width, height);
                
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
                Utils.set_context_color(cr, background_color);
                var first_draw_dot = draw_dots[0];
                var rest_draw_dots = draw_dots[1:draw_dots.size];
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
        
        public void draw_drag_frame(Cairo.Context cr) {
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
    }

    public void init_layout(Layout layout, string type, int x, int y, int w, int h) {
        layout.x = x;
        layout.y = y;
        layout.width = w;
        layout.height = h;
        layout.type = type;
    }

    public Layout create_rectangle_layout(string type, int x, int y, int w, int h) {
        var layout = new Layout();
        init_layout(layout, type, x, y, w, h);

        layout.add_draw_dot(x, y);
        layout.add_draw_dot(x + w, y);
        layout.add_draw_dot(x + w, y + h);
        layout.add_draw_dot(x, y + h);

        return layout;
    }

    public Layout create_rounded_rectangle_layout(string type, int x, int y, int w, int h) {
        var layout = new Layout();
        init_layout(layout, type, x, y, w, h);

        var r = 4;
        
        layout.add_draw_dot(x + w - r, y + r, r, Math.PI * 3 / 2, Math.PI * 2);
        layout.add_draw_dot(x + w - r, y + h - r, r, 0, Math.PI / 2);
        layout.add_draw_dot(x + r, y + h - r, r, Math.PI / 2, Math.PI);
        layout.add_draw_dot(x + r, y + r, r, Math.PI, Math.PI * 3 / 2);
        
        return layout;
    }

    public Layout create_triangle_layout(string type, int x, int y, int w, int h) {
        var layout = new Layout();
        init_layout(layout, type, x, y, w, h);

        layout.add_draw_dot(x + w / 2, y);
        layout.add_draw_dot(x + w, y + h);
        layout.add_draw_dot(x, y + h);

        return layout;
    }

    public Layout create_five_pointed_star_layout(string type, int x, int y, int w, int h) {
        var layout = new Layout();
        init_layout(layout, type, x, y, w, h);
        
        var star_number = 5;
        var star_points = star_number * 2 + 1;
        var alpha = (2 * Math.PI) / (star_number * 2); 
        var radius = int.min(w, h) / 2;
        var scale = int.max(w, h) / int.min(w, h);
        
        for (var i = star_points; i != 0; i--) {
            var r = radius * (i % 2 + 1) / 2;
            var omega = alpha * i;
            if (w > h) {
                layout.add_draw_dot((int) (r * Math.sin(omega) * scale) + (x + w / 2), (int) (r * Math.cos(omega)) + (y + h / 2));
            } else {
                layout.add_draw_dot((int) (r * Math.sin(omega)) + (x + w / 2), (int) (r * Math.cos(omega) * scale) + (y + h / 2));
            }
        }
        
        return layout;
    }

    public Layout create_pentagon_layout(string type, int x, int y, int w, int h) {
        var layout = new Layout();
        init_layout(layout, type, x, y, w, h);

        var star_number = 5;
        var star_points = star_number * 2 + 1;
        var alpha = (2 * Math.PI) / (star_number * 2); 
        var radius = int.min(w, h) / 2;
        var scale = int.max(w, h) / int.min(w, h);
        
        for (var i = star_points; i != 0; i--) {
            if (i % 2 != 0) {
                var r = radius * (i % 2 + 1) / 2;
                var omega = alpha * i;
                if (w > h) {
                    layout.add_draw_dot((int) (r * Math.sin(omega) * scale) + (x + w / 2), (int) (r * Math.cos(omega)) + (y + h / 2));
                } else {
                    layout.add_draw_dot((int) (r * Math.sin(omega)) + (x + w / 2), (int) (r * Math.cos(omega) * scale) + (y + h / 2));
                }
            }
        }
        
        return layout;
    }

    public Layout create_oval_layout(string type, int x, int y, int w, int h) {
        var layout = new Layout();
        init_layout(layout, type, x, y, w, h);
        
        return layout;
    }

    public Layout create_line_layout(string type, int x, int y, int w, int h) {
        var layout = new Layout();
        init_layout(layout, type, x, y, w, h);
        
        layout.add_draw_dot(x, y);
        layout.add_draw_dot(x + w, y + h);
        
        return layout;
    }
}