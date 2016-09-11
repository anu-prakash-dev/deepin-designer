using Gee;

namespace Layouts {
    public class DrawDot {
        public int x;
        public int y;

        public DrawDot(int dot_x, int dot_y) {
            x = dot_x;
            y = dot_y;
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

        public Layout() {
            frame_color = Utils.hex_to_rgba("#303030", 0.1);
            background_color = Utils.hex_to_rgba("#ff0000", 0.1);

            drag_dot_frame_color = Utils.hex_to_rgba("#000000", 0.5);
            drag_dot_background_color = Utils.hex_to_rgba("#333333", 0.1);

            draw_dots = new ArrayList<DrawDot>();
        }

        public void draw_layout(Cairo.Context cr) {
            if (draw_dots.size > 1) {
                Utils.set_context_color(cr, background_color);
                cr.move_to(draw_dots[0].x, draw_dots[0].y);
                foreach (var dot in draw_dots[1:draw_dots.size]) {
                    cr.line_to(dot.x, dot.y);
                }
                cr.close_path();
                cr.stroke();

                Utils.set_context_color(cr, frame_color);
                cr.move_to(draw_dots[0].x, draw_dots[0].y);
                foreach (var dot in draw_dots[1:draw_dots.size]) {
                    cr.line_to(dot.x, dot.y);
                }
                cr.close_path();
                cr.fill();
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

        public void add_draw_dot(int x, int y) {
            var dot = new DrawDot(x, y);
            draw_dots.add(dot);
        }
    }

    public void init_layout(Layout layout, int x, int y, int w, int h) {
        layout.x = x;
        layout.y = y;
        layout.width = w;
        layout.height = h;
    }

    public Layout create_rectangle_layout(int x, int y, int w, int h) {
        var layout = new Layout();
        init_layout(layout, x, y, w, h);

        layout.add_draw_dot(x, y);
        layout.add_draw_dot(x + w, y);
        layout.add_draw_dot(x + w, y + h);
        layout.add_draw_dot(x, y + h);

        return layout;
    }

    public Layout create_triangle_layout(int x, int y, int w, int h) {
        var layout = new Layout();
        init_layout(layout, x, y, w, h);

        layout.add_draw_dot(x + w / 2, y);
        layout.add_draw_dot(x + w, y + h);
        layout.add_draw_dot(x, y + h);

        return layout;
    }

    public Layout create_five_pointed_star_layout(int x, int y, int w, int h) {
        var layout = new Layout();
        init_layout(layout, x, y, w, h);

        int outside_y_offset = (int) Math.sqrt(((double) Math.pow(w, 2) * Math.pow(h, 2) + 4 * Math.pow(h, 4)) / ((double) 9 * Math.pow(w, 2) + 36 * Math.pow(h, 2)));
        int outside_x_offset = (int) (((double) (outside_y_offset * w)) / ((double) (2 * h)));
        int inside_y_offset = (int) ((Math.pow(w, 2) / 4 + Math.pow(h, 2)) / (2 * h));
        int inside_b_y_offset = (int) (((double) (1 - ((double) 2 * outside_x_offset) / w)) / (((double) (1 / ((double) 2 * h))) + ((double) (1 / ((double) (inside_y_offset - outside_y_offset))))));
        int inside_b_x_offset = (int) (w * inside_b_y_offset / (double) 2 / (double) h);
        
        // Outside a dot.
        layout.add_draw_dot(x + w / 2, y);

        // Inisde a dot.
        layout.add_draw_dot(x + w / 2 + outside_x_offset, y + outside_y_offset);
        
        // Outside b dot.
        layout.add_draw_dot(x + w, y + outside_y_offset);

        // Inisde b dot.
        layout.add_draw_dot(x + w / 2 + outside_x_offset + inside_b_x_offset, y + outside_y_offset + inside_b_y_offset);
        
        // Outside c dot.
        layout.add_draw_dot(x + w, y + h);
        
        // Inisde c dot.
        layout.add_draw_dot(x + w / 2, y + inside_y_offset);
        
        // Outside d dot.
        layout.add_draw_dot(x, y + h);
        
        // Inisde d dot.
        layout.add_draw_dot(x + w / 2 - outside_x_offset - inside_b_x_offset, y + outside_y_offset + inside_b_y_offset);
        
        // Outside e dot.
        layout.add_draw_dot(x, y + outside_y_offset);
        
        // Inisde e dot.
        layout.add_draw_dot(x + w / 2 - outside_x_offset, y + outside_y_offset);

        return layout;
    }

    public Layout create_pentagon_layout(int x, int y, int w, int h) {
        var layout = new Layout();
        init_layout(layout, x, y, w, h);

        int outside_y_offset = (int) Math.sqrt(((double) Math.pow(w, 2) * Math.pow(h, 2) + 4 * Math.pow(h, 4)) / ((double) 9 * Math.pow(w, 2) + 36 * Math.pow(h, 2)));
        int outside_x_offset = (int) (((double) (outside_y_offset * w)) / ((double) (2 * h)));
        
        // Outside a dot.
        layout.add_draw_dot(x + w / 2, y);

        // Outside b dot.
        layout.add_draw_dot(x + w, y + outside_y_offset);

        // Outside c dot.
        layout.add_draw_dot(x + w / 2 + outside_x_offset, y + h);
        
        // Outside d dot.
        layout.add_draw_dot(x + w / 2 - outside_x_offset, y + h);
        
        // Outside e dot.
        layout.add_draw_dot(x, y + outside_y_offset);
        
        return layout;
    }
}