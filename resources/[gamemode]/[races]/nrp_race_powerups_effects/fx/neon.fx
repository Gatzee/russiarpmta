#include "mta-helper.fx"

// Дистанция по затуханию от расстояния
const float fadedist = 5;

// Всё остальное ставит Lua
float scale = 4;
float3 pos = 0;
float3 mt = 0;
float3 rt = 0;
float4 rgba = float4(1,1,1,1);
float galpha = 1;
float3 def_normal = float3( 0, 0, 1 );
texture tex;

sampler Sampler0 = sampler_state
{
  Texture = <tex>;
};

struct vsin
{
  float4 Position : POSITION;
  float3 Normal : NORMAL0;
};

struct vsout
{
  float4 Position : POSITION;
  float3 WorldPos : TEXCOORD2;
  float3 Normal : TEXCOORD3;
};

vsout vs(vsin input)
{
  vsout output;
  //MTAFixUpNormal(input.Normal);
  output.Position = mul(input.Position,gWorldViewProjection);
  output.WorldPos = MTACalcWorldPosition(input.Position);
  if ( length( input.Normal ) == 0 ) {
    input.Normal = def_normal;
  }
  output.Normal = MTACalcWorldNormal(input.Normal);
  return output;
}
 
float4 ps(vsout input) : COLOR0
{
  clip( galpha );
  // Получаем относительный вектор позиции
  float3 vec = input.WorldPos - pos;

  // Проверяем угол поворота, чтобы не рисовать над машиной
  float deg = dot(vec,mt)/length(vec);
  clip(deg);

  // Альфа канал по расстоянию от автомобиля. Если <= 0, то не нужно делать дальнейшие расчеты
  float nd = (fadedist-length(deg*vec))/fadedist;
  clip(nd);

  // Синусы и косинусы наших углов поворота
  float3 sinn,coss;
  sincos(rt,sinn,coss);

  // Матрицы поворота
  float3x3 matrixX = {1.0f,0.0f,0.0f,0.0f,coss.y,-sinn.y,0.0f,sinn.y,coss.y};
  float3x3 matrixY = {coss.x,0.0f,sinn.x,0.0f,1.0f,0.0f,-sinn.x,0.0f,coss.x};
  float3x3 matrixZ = {coss.z,-sinn.z,0.0f,sinn.z,coss.z,0.0f,0.0f,0.0f,1.0f};

  // Преобразование пространства путём поворота
  float3 position = mul(matrixX,mul(matrixY,mul(matrixZ,vec)));

  // Масштаб изображения
  position /= scale;

  // Рисуем только в пределах размера текстуры
  if (abs(position.x) > 0.5f || abs(position.y) > 0.5f)
    discard;

  // Сдвиг до середины авто
  position += 0.5f;

  // Получаем цвет пикселя
  float4 color = tex2D(Sampler0,position);

  // Учёт дистанции
  color.a *= galpha;

  // Учёт нормали текстуры
  float DirectionFactor = max(0,abs(dot(input.Normal, -mt)));
  color.a *= DirectionFactor + 0.1;
  
  // Учёт кастомного цвета и прозрачности
  return color*rgba;
}
 
technique tec
{
  pass Pass0
  {
    // Чтоб не было графических проблем наложения
    DepthBias = -0.0005;
    // Ну и рендерим в шейдерной модели 3
    VertexShader = compile vs_3_0 vs();
    PixelShader = compile ps_3_0 ps();
  }
}