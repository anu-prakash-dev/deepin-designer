using Gtk;

namespace Widgets {
    public class PageManager : Gtk.VBox {
        public Widgets.Page focus_page;
        
        public PageManager() {
            new_page();
        }
        
        public void new_page() {
            var page = new Widgets.Page();

            Utils.remove_all_children(this);
            pack_start(page, true, true, 0);
            
            focus_page = page;
        }
    }
}