using Gtk;

namespace Widgets {
    public class Workspace : Gtk.HBox {
        public Widgets.PagePanel page_panel;
        public Widgets.PageManager page_manager;
        public Widgets.LayoutPanel layout_panel;
        
        public Workspace() {
            page_manager = new Widgets.PageManager();
            page_panel = new PagePanel();
            layout_panel = new LayoutPanel();            

            pack_start(page_panel, false, false, 0);
            pack_start(page_manager, true, true, 0);
            pack_start(layout_panel, false, false, 0);
        }
    }
}