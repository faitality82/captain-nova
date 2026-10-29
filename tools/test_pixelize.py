import os, sys, tempfile, unittest
sys.path.insert(0, os.path.dirname(__file__))
from PIL import Image
import pixelize


class PixelizeTest(unittest.TestCase):
    def _make_source(self, path):
        # 128x128 black background, a 64x64 pure-red square in the middle,
        # plus a near-black speck that must ALSO be keyed out (Imagen bg is not always #000).
        img = Image.new("RGB", (128, 128), (0, 0, 0))
        for y in range(32, 96):
            for x in range(32, 96):
                img.putpixel((x, y), (255, 0, 0))
        img.putpixel((2, 2), (1, 3, 18))
        img.save(path)

    def test_key_crop_scale(self):
        with tempfile.TemporaryDirectory() as d:
            src = os.path.join(d, "src.png")
            dst = os.path.join(d, "dst.png")
            self._make_source(src)
            pixelize.pixelize(src, dst, height=16, colors=8, key_black=True)
            out = Image.open(dst).convert("RGBA")
            # Cropped to the red square's bbox, then scaled to 16 px tall: 16x16.
            self.assertEqual(out.size, (16, 16))
            r, g, b, a = out.getpixel((8, 8))
            self.assertEqual(a, 255)
            self.assertGreater(r, 200)
            self.assertLess(g, 40)

    def test_no_crop_keeps_transparent_corners(self):
        with tempfile.TemporaryDirectory() as d:
            src = os.path.join(d, "src.png")
            dst = os.path.join(d, "dst.png")
            self._make_source(src)
            pixelize.pixelize(src, dst, height=32, colors=8, key_black=True, crop=False)
            out = Image.open(dst).convert("RGBA")
            self.assertEqual(out.size, (32, 32))
            self.assertEqual(out.getpixel((0, 0))[3], 0)   # keyed background is transparent
            self.assertEqual(out.getpixel((16, 16))[3], 255)

    def test_interior_dark_pixels_survive(self):
        with tempfile.TemporaryDirectory() as d:
            src = os.path.join(d, "src.png")
            dst = os.path.join(d, "dst.png")
            img = Image.new("RGB", (128, 128), (0, 0, 0))
            for y in range(32, 96):
                for x in range(32, 96):
                    img.putpixel((x, y), (255, 0, 0))
            # 6x6 pure-black block inside the red square (interior, not border-connected).
            for y in range(60, 66):
                for x in range(60, 66):
                    img.putpixel((x, y), (0, 0, 0))
            img.save(src)

            # Cropped variant: bbox is (32,32)-(96,96), so the interior black
            # block at (60..66, 60..66) lands at (28..34, 28..34) post-crop.
            pixelize.pixelize(src, dst, height=64, colors=8, key_black=True)
            out = Image.open(dst).convert("RGBA")
            self.assertEqual(out.size, (64, 64))
            self.assertEqual(out.getpixel((31, 31))[3], 255)

            # Uncropped variant: the true image-corner background is still keyed out.
            dst2 = os.path.join(d, "dst2.png")
            pixelize.pixelize(src, dst2, height=128, colors=8, key_black=True, crop=False)
            out2 = Image.open(dst2).convert("RGBA")
            self.assertEqual(out2.getpixel((0, 0))[3], 0)


if __name__ == "__main__":
    unittest.main()
