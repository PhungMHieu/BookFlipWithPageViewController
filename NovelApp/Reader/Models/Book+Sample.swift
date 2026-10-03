//
//  Book+Sample.swift
//  NovelApp
//

import Foundation

extension Book {
    /// Các truyện mẫu trong tủ sách.
    static let library: [Book] = [.lighthouse, .cottonTree]

    static let lighthouse = Book(
        id: "ngon-hai-dang-cuoi-cung",
        title: "Ngọn Hải Đăng Cuối Cùng",
        author: "Minh Hiếu",
        coverHue: 0.58,
        chapters: [
            Chapter(
                label: "Chương Một",
                title: "Người Gác Đèn",
                paragraphs: [
                    "Hòn đảo nhỏ ấy nằm ở cuối bản đồ, nơi những con tàu chở hàng chỉ còn là những chấm sáng mờ trôi qua đường chân trời. Trên đảo có một ngọn hải đăng sơn trắng đã bạc màu vì gió muối, và trong ngọn hải đăng có ông Tư, người gác đèn đã sống ở đó lâu đến mức chẳng ai trong làng chài bên kia vịnh còn nhớ ông đến từ khi nào.",
                    "Mỗi chiều, khi mặt trời bắt đầu chìm xuống biển như một đồng xu đồng nung đỏ, ông Tư lại leo lên một trăm mười hai bậc thang xoắn ốc. Ông đếm từng bậc, không phải vì sợ quên, mà vì đó là cách ông trò chuyện với ngọn tháp. Bậc thứ ba mươi kêu cót két. Bậc thứ bảy mươi có một vết nứt hình con cá. Bậc cuối cùng luôn lạnh hơn những bậc khác, dù trời có nóng đến đâu.",
                    "Trên đỉnh tháp, ông lau tấm kính hội tụ bằng một mảnh vải bông đã sờn, cẩn thận như người ta lau mắt kính cho một đứa trẻ. Rồi ông châm đèn. Ánh sáng quét một vòng dài trên mặt nước đen, chạm vào những rạn đá ngầm, những con sóng bạc đầu, và đôi khi chạm cả vào một cánh chim hải âu muộn màng đang tìm đường về tổ.",
                    "Người ta bảo rằng bây giờ tàu thuyền đã có định vị vệ tinh, chẳng còn ai cần đến hải đăng nữa. Ông Tư nghe vậy chỉ cười. Ông biết có những đêm bão lớn, máy móc im bặt như bị ai bịt miệng, và khi ấy người ta vẫn ngẩng đầu tìm một đốm sáng quen thuộc ở phía xa, giống như ông bà ta ngày xưa vẫn ngẩng đầu tìm sao Bắc Đẩu.",
                    "Ông sống một mình, nhưng không cô đơn. Ông có một con mèo mướp tên là Mực, một khu vườn nhỏ trồng rau muống và hành lá sau tháp, một chiếc radio cũ chỉ bắt được đúng một đài phát thanh, và một chồng sổ ghi chép dày cộm mà ông viết mỗi đêm từ hơn ba mươi năm nay. Trong đó ông ghi lại hướng gió, độ cao của sóng, và tên của từng con tàu đi ngang qua.",
                    "Có những trang chỉ ghi vài dòng ngắn ngủi: \"Gió mùa đông bắc. Biển động cấp năm. Không có tàu.\" Nhưng cũng có những trang ông viết kín cả hai mặt, kể về một chiếc thuyền buồm lạc hướng mà ông đã dẫn vào vịnh bằng cách nháy đèn theo mã Morse suốt ba tiếng đồng hồ, hay về một đàn cá heo đã bơi theo vệt sáng của ngọn đèn cho đến tận rạng sáng.",
                    "Đêm hôm đó, khi ông vừa đặt bút xuống, Mực bỗng dựng đứng lông lên và nhìn chằm chằm ra cửa sổ. Ông Tư nhìn theo. Ngoài khơi, ngay giữa vùng biển đen kịt nơi chẳng có con tàu nào được phép đi qua, có một đốm sáng xanh nhạt đang chớp tắt, chậm rãi và đều đặn, như thể ai đó đang cố gắng nói chuyện với ông.",
                ]
            ),
            Chapter(
                label: "Chương Hai",
                title: "Tín Hiệu Từ Biển",
                paragraphs: [
                    "Ông Tư dụi mắt, tưởng mình nhìn nhầm. Nhưng đốm sáng vẫn ở đó, ba lần ngắn, ba lần dài, rồi lại ba lần ngắn. Ông đã thuộc lòng tín hiệu ấy từ thời còn là một cậu bé phụ việc trên tàu đánh cá của cha. Đó là tín hiệu cấp cứu, thứ âm thanh không lời mà mọi người đi biển đều mong cả đời không bao giờ phải nhìn thấy.",
                    "Ông vội vàng quay ngọn đèn lớn về phía đốm sáng và nháy lại: \"Tôi thấy bạn.\" Đốm sáng xanh dừng lại trong giây lát, rồi bắt đầu chớp nhanh hơn, dồn dập hơn, những ký tự nối nhau như một người đang nói trong hơi thở gấp. Ông Tư lấy cuốn sổ, ghi lại từng chữ một bằng nét chữ run run.",
                    "\"Không có động cơ. Nước vào. Hai người. Một đứa trẻ.\" Ông đọc lại dòng chữ ấy ba lần. Ngoài kia, gió đã bắt đầu đổi hướng, và những đám mây thấp đang kéo đến từ phía nam, mang theo mùi tanh nồng của cơn mưa sắp tới. Ông biết chỉ trong vòng một giờ nữa, biển sẽ không còn là nơi dành cho một chiếc thuyền không có động cơ.",
                    "Ông gọi vào bộ đàm của trạm cứu hộ trên đất liền. Tiếng rè rè kéo dài như một tiếng thở dài mệt mỏi, rồi một giọng nói ngái ngủ vang lên. Họ hứa sẽ cho tàu ra, nhưng phải chờ ít nhất hai tiếng vì cơn bão đang chặn ngang cửa sông. Hai tiếng. Ông Tư nhìn đốm sáng xanh đang nhỏ dần đi trên mặt nước và hiểu rằng hai tiếng là quá lâu.",
                    "Dưới chân tháp, buộc vào một cọc gỗ mục, là chiếc xuồng máy cũ ông dùng để sang làng chài mua gạo mỗi tháng một lần. Máy của nó khó tính như một ông già, phải giật dây ba bốn lượt mới chịu nổ, và chưa bao giờ ông đưa nó ra xa quá rạn san hô. Ông đứng trên đỉnh tháp thêm một lúc, nhìn xuống chiếc xuồng, rồi nhìn ra biển.",
                    "Mực kêu lên một tiếng nhỏ, cọ đầu vào chân ông. Ông cúi xuống vuốt ve nó, rồi chỉnh lại ngọn đèn để nó quét đúng về phía đốm sáng xanh, khóa cố định ở đó. \"Mày trông nhà nhé,\" ông nói, giọng bình thản như mọi buổi chiều ông vẫn nói với nó trước khi đi ngủ. Rồi ông bắt đầu bước xuống một trăm mười hai bậc thang.",
                    "Lần này, ông không đếm.",
                ]
            ),
            Chapter(
                label: "Chương Ba",
                title: "Vệt Sáng Trên Mặt Nước",
                paragraphs: [
                    "Biển đêm không giống biển ngày. Ban ngày, nó là một tấm thảm xanh trải rộng, có đường chân trời để mắt người ta tựa vào. Ban đêm, nó là một cái miệng đen không đáy, và thứ duy nhất ngăn cách ông Tư với cái miệng ấy là lớp tôn mỏng của chiếc xuồng cũ đang chồm lên, hụp xuống theo từng ngọn sóng.",
                    "Nhưng ông không lạc. Phía sau lưng ông, ngọn hải đăng vẫn đứng đó, chiếu một vệt sáng dài và thẳng tắp ra biển như một sợi chỉ vàng căng giữa bóng tối. Ông chỉ cần đi theo sợi chỉ ấy. Suốt ba mươi năm, ông đã dùng ánh sáng ấy để dẫn đường cho người khác. Đêm nay, lần đầu tiên, nó dẫn đường cho chính ông.",
                    "Mưa bắt đầu rơi, những hạt mưa to và nặng như sỏi, quất vào mặt ông rát buốt. Chiếc xuồng chòng chành dữ dội. Có lúc một con sóng lớn đổ ập vào mạn thuyền, nước tràn vào đến mắt cá chân, và máy xuồng ho sặc sụa như sắp tắt. Ông Tư nghiến răng, một tay giữ chặt cần lái, một tay tát nước bằng chiếc gáo dừa.",
                    "Rồi ông nhìn thấy họ. Một chiếc thuyền gỗ nhỏ đã nghiêng hẳn sang một bên, mũi thuyền chúc xuống nước. Một người đàn ông trẻ đang bám vào mạn thuyền, tay còn lại giơ cao chiếc đèn pin bọc trong túi ni lông màu xanh, thứ ánh sáng mà ông đã thấy từ trên đỉnh tháp. Bên cạnh anh, quấn trong chiếc áo phao quá khổ, là một bé gái chừng sáu tuổi.",
                    "Ông Tư không nhớ rõ mình đã đưa hai người họ lên xuồng bằng cách nào. Ông chỉ nhớ đôi tay nhỏ bé lạnh ngắt của đứa trẻ bám chặt lấy cổ áo ông, và tiếng người đàn ông lặp đi lặp lại một câu cảm ơn đứt quãng giữa tiếng gió. Ông nhớ mình đã quay mũi xuồng về phía ngọn hải đăng, và vệt sáng vàng ấy vẫn ở đó, kiên nhẫn chờ đợi họ.",
                    "Khi chiếc xuồng chạm vào bờ đá, trời đã bắt đầu hửng sáng. Cơn bão đi qua nhanh như lúc nó đến, để lại một mặt biển phẳng lặng màu ngọc trai. Mực ngồi đợi ở bậc cửa, đuôi cuộn tròn quanh chân. Từ xa, tiếng còi tàu cứu hộ vang lên, muộn màng nhưng vẫn khiến người ta thấy ấm lòng.",
                    "Đêm hôm sau, ông Tư lại leo lên một trăm mười hai bậc thang. Lần này ông đếm, chậm rãi, từng bậc một. Ông lau kính, châm đèn, rồi mở cuốn sổ ra và viết: \"Gió nhẹ. Biển êm. Có một đứa trẻ đã về nhà.\" Rồi ông gấp sổ lại, ngồi xuống cạnh Mực, và cùng nó nhìn ngọn đèn quét những vòng dài, chậm rãi, trên mặt biển đêm.",
                ]
            ),
        ]
    )
}
