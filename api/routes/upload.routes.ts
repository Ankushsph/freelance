import { Router } from "express";
import multer from "multer";
import path from "path";
import fs from "fs";

const router = Router();

// Validate URL endpoint - check if URL is publicly accessible
router.post("/validate-url", async (req, res) => {
  const { url } = req.body;
  
  if (!url) {
    return res.status(400).json({ 
      success: false, 
      error: "URL is required" 
    });
  }
  
  try {
    console.log(`[Upload] Validating URL: ${url}`);
    
    const response = await fetch(url, { 
      method: "HEAD",
      headers: {
        'User-Agent': 'Mozilla/5.0 (compatible; KonnectAPI/1.0)'
      }
    });
    
    if (!response.ok) {
      return res.status(400).json({
        success: false,
        valid: false,
        error: `URL returned status ${response.status}`,
        status: response.status
      });
    }
    
    const contentType = response.headers.get("content-type");
    const contentLength = response.headers.get("content-length");
    
    if (!contentType || !contentType.startsWith("image/")) {
      return res.status(400).json({
        success: false,
        valid: false,
        error: "URL does not point to a valid image",
        contentType: contentType
      });
    }
    
    res.json({
      success: true,
      valid: true,
      url: url,
      contentType: contentType,
      size: contentLength ? parseInt(contentLength) : null
    });
    
  } catch (error: any) {
    console.error(`[Upload] URL validation error:`, error);
    res.status(400).json({
      success: false,
      valid: false,
      error: `Cannot access URL: ${error.message}`
    });
  }
});

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadPath = "uploads/";
    if (!fs.existsSync(uploadPath)) {
      fs.mkdirSync(uploadPath);
    }
    cb(null, uploadPath);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
    cb(null, uniqueSuffix + path.extname(file.originalname));
  },
});

const upload = multer({ storage: storage });

router.post("/", upload.single("file"), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ message: "No file uploaded" });
  }
  
  // Use PUBLIC_URL from env if available, otherwise construct from request
  // PUBLIC_URL should be your public domain like https://api.codesbyjit.site
  const publicUrl = process.env.PUBLIC_URL;
  const fileUrl = publicUrl 
    ? `${publicUrl}/uploads/${req.file.filename}`
    : `${req.protocol}://${req.get("host")}/uploads/${req.file.filename}`;
  
  console.log(`[Upload] File uploaded: ${req.file.originalname} -> ${fileUrl}`);
  res.json({ 
    success: true,
    url: fileUrl,
    filename: req.file.filename,
    originalName: req.file.originalname,
    size: req.file.size
  });
});

export default router;
