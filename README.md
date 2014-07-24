Natural-Language-Generation
===========================
Run 'coffee app.coffee'

Description:
------------
โปรแกรมแบ่งเป็น 2 ส่วนคือ
1. Data Preparation: เตรียมข้อมูลที่จำเป็นสำหรับการสร้างประโยค
2. Sentence Generation: นำ data จากข้อหนึ่งมาเขียนเป็นประโยค

### Data Preparation
ข้อมูลที่ต้องเตรียมมีดังนี้
1. เปลี่ยนข้อมูล input ให้เป็นตัวเลขที่นำไปคำนวณต่อได้
2. คำนวณความแตงต่างของข้อมูลเก่าและข้อมูลใหม่ (difference)
3. นำค่าความแตกต่างมาตีเป็นระดับความรุนแรงของการเปลี่ยนแปลง (level)
4. แบ่งกลุ่มของการเปลี่ยนแปลงว่าเป็นการเปลี่ยนแปลงในทางบวก, ไม่เปลี่ยนแปลง หรือเปลี่ยนแปลงในทางลบ (levelType)
5. 

Sample output:
--------------

#### Short
⋅⋅⋅The price has decreased from 53% to 62.62% below jitta line. Jitta score looks good at 7.0. The price has significantly decreased by 16% to 80 baht. CapEx is very low, and there is share repurchase every year.

#### Full
⋅⋅⋅The price has decreased from 53% to 62.62% below jitta line. Jitta score is still good at 7.0. The price has extremely dropped to 80 baht. CapEx is very low, and there is share repurchase every year. Operating margin is declined, but dividend payout is increasing every year. There is return on equity, but earning loss detected in the past years. Return on equity is still consistently high. Growth opportunity has significantly decreased by 30 to 60, but competitive advantage has increased by 2 to 100. Recent business performance has raised from 35 to 50 and return to share holder is still good at 69. Financial strength is still good at 100.