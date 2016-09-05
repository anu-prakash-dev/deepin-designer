using Gtk;

namespace Widgets {
    public class Workspace : Gtk.Overlay {
        public Widgets.PageManager page_manager;
        public Widgets.PagePanelBox page_panel_box;
        public Widgets.LayoutPanelBox layout_panel_box;
        
        public Workspace() {
            page_manager = new Widgets.PageManager();
            page_panel_box = new PagePanelBox();
            layout_panel_box = new LayoutPanelBox();            
            
            add(page_manager);
            add_overlay(page_panel_box);
            add_overlay(layout_panel_box);
        }
    }
}