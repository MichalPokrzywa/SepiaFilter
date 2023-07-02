using System;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Runtime.InteropServices;
using System.Threading;
using System.Windows.Forms;
using JACsharp;

namespace JA_ProjectMain
{
    public partial class JA_project : Form
    {
        private byte[] byteBuffer;
        private int numberOfThreads;
        private int numberToFinish;
        private int referenceTableNumber;
        private Semaphore sem = new Semaphore(1, 1);
        String asmDLL = System.Reflection.Assembly.GetEntryAssembly().Location;

        [DllImport(@"JA_Asm.dll")]
        private static extern void SepiaTone(byte[] tableBytes);

        public JA_project()
        {
            var lol = System.Reflection.Assembly.GetEntryAssembly().Location;
            InitializeComponent();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            if (textBox1.Text != "")
            {
                FileInfo fi = new FileInfo(textBox1.Text);
                if (textBox1.Text != null && File.Exists(textBox1.Text) &&
                    (fi.Extension == ".png" || fi.Extension == ".jpg"))
                {
                    if (checkBox1.Checked)
                    {
                        string directory = fi.DirectoryName;
                        string file = fi.Name.Remove(fi.Name.Length - 4, 4);
                        if (!Directory.Exists(directory + "/" + file + "_TimeTests"))
                            Directory.CreateDirectory(directory + "/" + file + "_TimeTests");
                        string fileName = directory + "/" + file + "_TimeTests/";
                        var watch = Stopwatch.StartNew();
                        for (int o = 0; o < 2; o++)
                        {
                            for (int j = 1; j <= 64; j += j)
                            {
                                numberOfThreads = j;
                                fileName = fileName + file + "_pomiar";
                                if (o == 0)
                                {
                                    radioButton2.Checked = false;
                                    fileName = fileName + "_C#_" + j.ToString() + ".txt";
                                    radioButton1.Checked = true;
                                }
                                else
                                {
                                    radioButton1.Checked = false;
                                    fileName = fileName + "_asm_" + j.ToString() + ".txt";
                                    radioButton2.Checked = true;
                                }

                                for (int k = 0; k <= 100; k++)
                                {
                                    using (StreamWriter writer = new StreamWriter(fileName, true))
                                    {
                                        writer.WriteLine(MainProgram(true));
                                    }
                                }

                                fileName = directory + "/" + file + "_TimeTests/";
                            }
                        }

                        watch.Stop();
                        var elapsedMs = watch.Elapsed;
                        label3.Text = elapsedMs.ToString();
                        labelInfo.Text = @"Testing Complete";
                    }
                    else
                    {
                        label3.Text = MainProgram(false) + @" milliseconds";
                        labelInfo.Text = @"Conversion Complete";
                    }
                }
                else
                {
                    labelInfo.Text = @"Provide a good path for picture";
                }
            }
            else
            {
                labelInfo.Text = @"Provide a path for picture";
            }
        }

        private string MainProgram(bool isTest)
        {
            var newImage = Image.FromFile(textBox1.Text);
            var copyBitmap = new Bitmap((Bitmap)newImage);
            var bmpData = copyBitmap.LockBits(new Rectangle(0, 0, copyBitmap.Width, copyBitmap.Height),
                ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
            var ptr = bmpData.Scan0;
            var widthOfBitmap = bmpData.Stride;
            var boundaryOfBitmapTable = bmpData.Stride * bmpData.Height;
            byteBuffer = new byte[bmpData.Stride * bmpData.Height];
            Marshal.Copy(ptr, byteBuffer, 0, byteBuffer.Length);
            referenceTableNumber = 0;
            if (!isTest)
                numberOfThreads = (int)numericUpDown1.Value;
            numberToFinish = numberOfThreads;
            var watch = Stopwatch.StartNew();
            for (var i = 0; i < numberOfThreads; i++)
            {
                var newThread = new Thread(() => SendAddress(boundaryOfBitmapTable, widthOfBitmap));
                newThread.Start();
            }
            while (numberToFinish > 0);
            Marshal.Copy(byteBuffer, 0, ptr, byteBuffer.Length);
            copyBitmap.UnlockBits(bmpData);
            FileInfo fi = new FileInfo(textBox1.Text);
            copyBitmap.Save(fi.DirectoryName + "/" + fi.Name.Remove(fi.Name.Length - 4, 4) + "_sepia" + fi.Extension);
            pictureBox2.Image = copyBitmap;
            watch.Stop();
            var elapsedMs = watch.ElapsedMilliseconds;
            return elapsedMs.ToString();
        }

        private void SendAddress(int boundaryOfBitmapTable, int widthOfBitmap)
        {
            while (referenceTableNumber < boundaryOfBitmapTable)
            {
                sem.WaitOne();
                var currentTableNumber = referenceTableNumber;
                Interlocked.Add(ref referenceTableNumber, widthOfBitmap);
                sem.Release();
                if (currentTableNumber >= boundaryOfBitmapTable) break;
                CalculatePixel(currentTableNumber, widthOfBitmap);
            }
            Interlocked.Decrement(ref numberToFinish);
        }

        private void CalculatePixel(int currentTableNumber, int widthOfBitmap)
        {
            int starting = currentTableNumber;
            for (int i = currentTableNumber; i < starting + widthOfBitmap; i += 4)
            {
                var arrayBytes = new byte[3];
                arrayBytes[0] = byteBuffer[i + 2];
                arrayBytes[1] = byteBuffer[i + 1];
                arrayBytes[2] = byteBuffer[i];
                if (radioButton1.Checked)
                {
                    Converter.SepiaTone(ref arrayBytes);
                    byteBuffer[i + 2] = arrayBytes[0];
                    byteBuffer[i + 1] = arrayBytes[1];
                    byteBuffer[i] = arrayBytes[2];
                }
                else
                {
                    SepiaTone(arrayBytes);
                    byteBuffer[i + 2] = arrayBytes[0];
                    byteBuffer[i + 1] = arrayBytes[1];
                    byteBuffer[i] = arrayBytes[2];
                }
            }
        }

        private void textBox1_DragEnter(object sender, DragEventArgs e)
        {
            e.Effect = e.Data.GetDataPresent(DataFormats.FileDrop) ? DragDropEffects.Copy : DragDropEffects.None;
        }

        private void textBox1_DragDrop(object sender, DragEventArgs e)
        {
            textBox1.Text = "";
            var fileList = (string[])e.Data.GetData(DataFormats.FileDrop, false);
            FileInfo fi = new FileInfo(fileList[0]);
            if (fi.Exists && (fi.Extension == ".png" || fi.Extension == ".jpg"))
                textBox1.Text = fileList[0];
            else
                labelInfo.Text = @"Provide a good path for picture";
        }

        private void textBox1_TextChanged(object sender, EventArgs e)
        {
            pictureBox2.Image = null;
            if (textBox1.Text != "")
            {
                FileInfo fi = new FileInfo(textBox1.Text);
                if (File.Exists(textBox1.Text) && (fi.Extension == ".png" || fi.Extension == ".jpg"))
                {
                    var newImage = Image.FromFile(textBox1.Text);
                    pictureBox1.Image = newImage;
                }
                else
                {
                    pictureBox1.Image = null;
                }
            }
        }
    }
}