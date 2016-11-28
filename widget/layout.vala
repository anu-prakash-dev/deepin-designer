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

    public abstract class Layout {
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
        public abstract void update_track(int drag_start_x, int drag_start_y, int? drag_x, int? drag_y);
        
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

    public class TextLayout : Layout {
        public string text = "Type something";
        public int text_size = 20;
        public Gdk.RGBA text_color;
        
        public TextLayout() {
            text_color = Utils.hex_to_rgba("#000000", 1.0);
        }
        
        public override void draw_layout(Cairo.Context cr) {
            cr.save();
            
            Utils.set_context_color(cr, text_color);
            
            var font_description = new Pango.FontDescription();
            font_description.set_size((int)(text_size * Pango.SCALE));
        
            var layout = Pango.cairo_create_layout(cr);
            layout.set_font_description(font_description);
            layout.set_text(text, text.length);
            layout.set_alignment(Pango.Alignment.LEFT);

            int text_width, text_height;
            layout.get_pixel_size(out text_width, out text_height);
            
            width = text_width;
            height = text_height;

            int render_y;
            render_y = y + int.max(0, (height - text_height) / 2);
        
            cr.move_to(x, render_y);
            Pango.cairo_update_layout(cr, layout);
            Pango.cairo_show_layout(cr, layout);
        
            cr.restore();
        }
        
        public override void update_track(int drag_start_x, int drag_start_y, int? drag_x, int? drag_y) {
            can_draw = true;
            
            x = drag_start_x;
            y = drag_start_y;
        }
    }

    public class ShapeLayout : Layout {
        public Gdk.RGBA frame_color;
        public Gdk.RGBA background_color;
        public ArrayList<DrawDot> draw_dots;

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

        public override void update_track(int drag_start_x, int drag_start_y, int? drag_x, int? drag_y) {
        }
    }

    public class RectangleLayout : ShapeLayout {
        public override void update_track(int drag_start_x, int drag_start_y, int? drag_x, int? drag_y) {
            update_size(drag_start_x, drag_start_y, drag_x, drag_y);
            
            clean_draw_dots();
                
            add_draw_dot(x, y);
            add_draw_dot(x + width, y);
            add_draw_dot(x + width, y + height);
            add_draw_dot(x, y + height);
        }
    }

    public class RoundedRectangleLayout : ShapeLayout {
        public override void update_track(int drag_start_x, int drag_start_y, int? drag_x, int? drag_y) {
            update_size(drag_start_x, drag_start_y, drag_x, drag_y);
            
            clean_draw_dots();
            
            var r = 4;
        
            add_draw_dot(x + width - r, y + r, r, Math.PI * 3 / 2, Math.PI * 2);
            add_draw_dot(x + width - r, y + height - r, r, 0, Math.PI / 2);
            add_draw_dot(x + r, y + height - r, r, Math.PI / 2, Math.PI);
            add_draw_dot(x + r, y + r, r, Math.PI, Math.PI * 3 / 2);
        }
    }

    public class TriangleLayout : ShapeLayout {
        public override void update_track(int drag_start_x, int drag_start_y, int? drag_x, int? drag_y) {
            update_size(drag_start_x, drag_start_y, drag_x, drag_y);
            
            clean_draw_dots();
            
            add_draw_dot(x + width / 2, y);
            add_draw_dot(x + width, y + height);
            add_draw_dot(x, y + height);
        }
    }

    public class FivePointedStarLayout : ShapeLayout {
        public override void update_track(int drag_start_x, int drag_start_y, int? drag_x, int? drag_y) {
            update_size(drag_start_x, drag_start_y, drag_x, drag_y);
            
            clean_draw_dots();
            
            if (width > 0 && height > 0) {
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
            }
        }
    }

    public class PentagonLayout : ShapeLayout {
        public override void update_track(int drag_start_x, int drag_start_y, int? drag_x, int? drag_y) {
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

    public class LineLayout : ShapeLayout {
        public override void update_track(int drag_start_x, int drag_start_y, int? drag_x, int? drag_y) {
            update_size(drag_start_x, drag_start_y, drag_x, drag_y);
            
            clean_draw_dots();
            
            add_draw_dot(drag_start_x, drag_start_y);
            add_draw_dot(drag_x, drag_y);
        }
    }

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

        public override void update_track(int drag_start_x, int drag_start_y, int? drag_x, int? drag_y) {
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
        
        public override void update_track(int drag_start_x, int drag_start_y, int? drag_x, int? drag_y) {
            update_size(drag_start_x, drag_start_y, drag_x, drag_y);
        }        
    }
}