// language: Objective-C, file: Tweak.xm
#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <mach/vm_map.h>

// ==========================================
// KHAI BÁO OFFSET (Từ ảnh của mày)
// ==========================================
#define OFF_CAM_1           0x554b9ec
#define OFF_CAM_2           0x5561e44
#define BYTE_CAM            0x200080D2C0035FD6

#define OFF_HIEN_UNTY       0x5f1c2b4
#define BYTE_HIEN_UNTY      0x1F2003D5
#define OFF_HIEN_TOCAO      0x5f1c3ac
#define BYTE_TOCAO_1        0x330080D2 // Lưu ý: Đoạn này trong ảnh mày ghi là 330080D2, tao để nguyên
#define OFF_HIEN_BOTRO      0x5adf5a8
#define BYTE_BOTRO          0x200080D2C0035FD6

#define OFF_HACK_MAP        0x4A38174
#define BYTE_HACK_MAP       0x1F2003D5

#define OFF_AC_1            0x5A78334
#define OFF_AC_2            0x4BF89BC
#define OFF_AC_3            0x4BF90A0
#define OFF_AC_4            0x47EDCA8
#define OFF_AC_5            0x78B6D70
#define OFF_AC_6            0x78B6D00
#define OFF_AC_7            0x5CC137C
#define OFF_AC_8            0x4D9A320
#define OFF_AC_9            0x73B736C
#define BYTE_AC_RET         0xC0035FD6
#define BYTE_AC_7           0x000080D2C0035FD6

// ==========================================
// LOGIC PATCH BỘ NHỚ
// ==========================================
static uintptr_t g_baseAddr = 0;

uintptr_t get_base_address() {
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        const char *name = _dyld_get_image_name(i);
        if (name && (strstr(name, "UnityFramework") || strstr(name, "kgvn"))) {
            return (uintptr_t)_dyld_get_image_header(i);
        }
    }
    return 0;
}

void patch_mem(uintptr_t addr, uint64_t value, int byte_count) {
    vm_protect(mach_task_self(), addr, byte_count, false, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
    if (byte_count == 4) *(uint32_t*)addr = (uint32_t)value;
    else if (byte_count == 8) *(uint64_t*)addr = value;
    vm_protect(mach_task_self(), addr, byte_count, false, VM_PROT_READ | VM_PROT_EXECUTE);
}

void do_cam_xa() { if (!g_baseAddr) g_baseAddr = get_base_address(); patch_mem(g_baseAddr + OFF_CAM_1, BYTE_CAM, 8); patch_mem(g_baseAddr + OFF_CAM_2, BYTE_CAM, 8); }
void do_hack_map() { if (!g_baseAddr) g_baseAddr = get_base_address(); patch_mem(g_baseAddr + OFF_HACK_MAP, BYTE_HACK_MAP, 4); }
void do_hien_ui() { 
    if (!g_baseAddr) g_baseAddr = get_base_address(); 
    patch_mem(g_baseAddr + OFF_HIEN_UNTY, BYTE_HIEN_UNTY, 4); 
    patch_mem(g_baseAddr + OFF_HIEN_TOCAO, BYTE_TOCAO_1, 4); 
    patch_mem(g_baseAddr + OFF_HIEN_BOTRO, BYTE_BOTRO, 8); 
}
void do_bypass_ac() {
    if (!g_baseAddr) g_baseAddr = get_base_address();
    patch_mem(g_baseAddr + OFF_AC_1, BYTE_AC_RET, 4); patch_mem(g_baseAddr + OFF_AC_2, BYTE_AC_RET, 4);
    patch_mem(g_baseAddr + OFF_AC_3, BYTE_AC_RET, 4); patch_mem(g_baseAddr + OFF_AC_4, BYTE_AC_RET, 4);
    patch_mem(g_baseAddr + OFF_AC_5, BYTE_AC_RET, 4); patch_mem(g_baseAddr + OFF_AC_6, BYTE_AC_RET, 4);
    patch_mem(g_baseAddr + OFF_AC_7, BYTE_AC_7, 8); patch_mem(g_baseAddr + OFF_AC_8, BYTE_AC_RET, 4);
    patch_mem(g_baseAddr + OFF_AC_9, BYTE_AC_RET, 4);
}

// ==========================================
// UI MENU (TRUNG DŨNG - AOV)
// ==========================================
@interface TrungDungAOVMenu : UIView
@end

@implementation TrungDungAOVMenu

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Màu nền tím đen
        self.backgroundColor = [UIColor colorWithRed:0.12 green:0.05 blue:0.25 alpha:0.95];
        self.layer.cornerRadius = 10;
        self.layer.borderWidth = 2;
        self.layer.borderColor = [UIColor purpleColor].CGColor;

        // Thanh tiêu đề
        UIView *titleBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 40)];
        titleBar.backgroundColor = [UIColor colorWithRed:0.25 green:0.1 blue:0.45 alpha:1.0];
        [self addSubview:titleBar];

        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 40)];
        title.text = @"TRUNG DŨNG MENU - AOV";
        title.textColor = [UIColor whiteColor];
        title.font = [UIFont boldSystemFontOfSize:16];
        title.textAlignment = NSTextAlignmentCenter;
        [titleBar addSubview:title];

        // Nút tắt (X)
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        closeBtn.frame = CGRectMake(frame.size.width - 40, 5, 30, 30);
        [closeBtn setTitle:@"X" forState:UIControlStateNormal];
        [closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(hideMenu) forControlEvents:UIControlEventTouchUpInside];
        [titleBar addSubview:closeBtn];

        // Khung chứa các nút
        UIView *contentBox = [[UIView alloc] initWithFrame:CGRectMake(10, 50, frame.size.width - 20, 260)];
        contentBox.backgroundColor = [UIColor colorWithRed:0.2 green:0.1 blue:0.35 alpha:0.9];
        contentBox.layer.cornerRadius = 8;
        [self addSubview:contentBox];

        // Hàm tạo nút Toggle
        #define ADD_TOGGLE(title, yPos, action) { \
            UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(15, yPos + 5, 200, 20)]; \
            lbl.text = title; lbl.textColor = [UIColor whiteColor]; lbl.font = [UIFont boldSystemFontOfSize:14]; \
            [contentBox addSubview:lbl]; \
            UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(contentBox.frame.size.width - 60, yPos, 50, 30)]; \
            sw.onTintColor = [UIColor cyanColor]; \
            [sw addTarget:self action:@selector(action:) forControlEvents:UIControlEventValueChanged]; \
            [contentBox addSubview:sw]; \
        }

        ADD_TOGGLE(@"CAM XA", 10, toggleCam)
        ADD_TOGGLE(@"HACK MAP", 60, toggleMap)
        ADD_TOGGLE(@"HIỆN UNTY/TỐ CÁO", 110, toggleUI)
        ADD_TOGGLE(@"BYPASS AC", 160, toggleAC)

        // Hỗ trợ kéo thả menu
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:pan];
    }
    return self;
}

- (void)toggleCam:(UISwitch *)s { if (s.isOn) do_cam_xa(); }
- (void)toggleMap:(UISwitch *)s { if (s.isOn) do_hack_map(); }
- (void)toggleUI:(UISwitch *)s { if (s.isOn) do_hien_ui(); }
- (void)toggleAC:(UISwitch *)s { if (s.isOn) do_bypass_ac(); }

- (void)hideMenu {
    self.hidden = YES;
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self];
    self.center = CGPointMake(self.center.x + translation.x, self.center.y + translation.y);
    [gesture setTranslation:CGPointZero inView:self];
}
@end

// ==========================================
// HOOK CỬ CHỈ 3 NGÓN TAY 3 LẦN & KHỞI TẠO
// ==========================================
static TrungDungAOVMenu *aovMenu = nil;
static int tapCount = 0;

%hook UIWindow
- (instancetype)initWithFrame:(CGRect)frame {
    id ret = %orig;
    
    if (!aovMenu) {
        // Khởi tạo menu ẩn lúc đầu
        aovMenu = [[TrungDungAOVMenu alloc] initWithFrame:CGRectMake(20, 100, 340, 320)];
        aovMenu.hidden = YES;
        [self addSubview:aovMenu];

        // Thêm cử chỉ chạm 3 ngón tay
        UITapGestureRecognizer *threeFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleThreeFingerTap)];
        threeFingerTap.numberOfTouchesRequired = 3; // 3 ngón
        threeFingerTap.numberOfTapsRequired = 3;    // 3 lần
        [self addGestureRecognizer:threeFingerTap];
    }
    
    return ret;
}

- (void)handleThreeFingerTap {
    // Đảo ngược trạng thái ẩn/hiện của menu
    aovMenu.hidden = !aovMenu.hidden;
    
    // Đưa menu lên trên cùng
    if (!aovMenu.hidden) {
        [self bringSubviewToFront:aovMenu];
    }
}
%end