# 轻卡 AI 技术详细设计 v1

日期：2026-06-12  
目标版本：Flutter iOS 单机 MVP  
当前产品决策：先做单机版，不接 Java 服务端；客户端直接调用 DeepSeek；图片只作为 AI 解析输入，不长期保存，最终只保存结构化结果。

## 1. 技术目标

第一版目标是快速做出可在 iPhone 真机运行的减脂记录 App，功能闭环如下：

1. 用户本地登录或进入。
2. 填写昵称、手机号、身体信息和目标。
3. 首页展示今日进度、昨日回顾、今日计划。
4. 支持拍照识别饮食。
5. 支持手动记录饮食。
6. 支持上传运动截图识别运动。
7. AI 解析成功后，图片不保存，只保存解析后的结构化数据。
8. 支持历史记录、单日详情、推荐计划和我的页。

第一版不做：
- 服务端账号体系。
- 多设备同步。
- 云端图片存储。
- App Store 正式安全加固。
- Android 版本。

## 2. 总体架构

```text
Flutter iOS App
  ├─ UI 页面层
  ├─ Riverpod 状态管理
  ├─ 本地 Repository
  ├─ SQLite 本地数据库
  ├─ 本地设置存储
  ├─ DeepSeek AI 适配层
  └─ 图片临时读取与压缩
```

数据流：

```text
拍照 / 选择图片
  -> App 临时读取图片
  -> 压缩 / Base64 或 multipart 适配
  -> 调用 DeepSeek
  -> 得到 JSON 结构化结果
  -> 用户确认 / 修改
  -> SQLite 保存结构化数据
  -> 丢弃图片
```

## 3. Flutter 技术选型

### 3.1 基础

- Flutter stable。
- Dart。
- iOS first。
- 最低 iOS 版本建议：iOS 15 或 iOS 16。

### 3.2 推荐依赖

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.6.1
  go_router: ^14.8.1
  dio: ^5.8.0
  sqflite: ^2.4.1
  path: ^1.9.0
  path_provider: ^2.1.5
  shared_preferences: ^2.5.2
  flutter_secure_storage: ^9.2.4
  image_picker: ^1.1.2
  image: ^4.5.2
  intl: ^0.20.2
```

用途：
- `flutter_riverpod`：页面状态和业务状态。
- `go_router`：页面路由。
- `dio`：调用 DeepSeek API。
- `sqflite`：本地关系型数据。
- `shared_preferences`：简单开关、首次进入标记。
- `flutter_secure_storage`：DeepSeek API Key。
- `image_picker`：拍照、相册选择。
- `image`：图片压缩和尺寸处理。

## 4. 本地数据设计

### 4.1 设计原则

- 图片不入库。
- 图片不长期保存。
- 只保存用户确认后的结构化数据。
- 所有记录按日期查询。
- 第一版只考虑单用户本机使用。

### 4.2 表：user_profile

保存用户基础资料。

```sql
CREATE TABLE user_profile (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  phone TEXT NOT NULL,
  nickname TEXT,
  avatar_url TEXT,
  gender TEXT,
  age INTEGER,
  height_cm REAL,
  current_weight_kg REAL,
  target_weight_kg REAL,
  target_date TEXT,
  goal_speed TEXT,
  diet_preferences TEXT,
  exercise_level TEXT,
  daily_calorie_min INTEGER,
  daily_calorie_max INTEGER,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);
```

说明：
- `phone` 第一版可不做真实短信验证，作为本地账号标识。
- `diet_preferences` 第一版用 JSON 字符串保存。
- `target_date` 使用 `yyyy-MM-dd`。

### 4.3 表：diet_records

保存饮食记录。拍照识别和手动输入都进入这张表。

```sql
CREATE TABLE diet_records (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  record_date TEXT NOT NULL,
  meal_type TEXT NOT NULL,
  food_name TEXT NOT NULL,
  portion_level TEXT,
  calories INTEGER NOT NULL,
  source_type TEXT NOT NULL,
  ai_summary TEXT,
  confidence REAL,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);
```

字段：
- `meal_type`：breakfast、lunch、dinner、snack。
- `source_type`：photo、manual。
- `portion_level`：small、normal、large。
- `food_name`：一条食物一条记录，便于统计和修改。

### 4.4 表：exercise_records

保存运动记录。

```sql
CREATE TABLE exercise_records (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  record_date TEXT NOT NULL,
  exercise_type TEXT NOT NULL,
  duration_minutes INTEGER,
  distance_km REAL,
  calories_burned INTEGER NOT NULL,
  source_type TEXT NOT NULL,
  ai_summary TEXT,
  confidence REAL,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);
```

字段：
- `source_type`：screenshot、manual。

### 4.5 表：daily_plans

保存每日计划。

```sql
CREATE TABLE daily_plans (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  plan_date TEXT NOT NULL UNIQUE,
  calorie_min INTEGER NOT NULL,
  calorie_max INTEGER NOT NULL,
  breakfast_plan TEXT,
  lunch_plan TEXT,
  dinner_plan TEXT,
  exercise_plan TEXT,
  plan_status TEXT NOT NULL,
  ai_reason TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);
```

字段：
- `plan_status`：not_started、in_progress、completed、needs_adjustment。

### 4.6 表：daily_summaries

保存每日汇总结果，可由本地计算生成，也可以缓存。

```sql
CREATE TABLE daily_summaries (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  record_date TEXT NOT NULL UNIQUE,
  intake_calories INTEGER NOT NULL,
  burned_calories INTEGER NOT NULL,
  status TEXT NOT NULL,
  ai_daily_summary TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);
```

### 4.7 表：app_settings

保存本机设置。

```sql
CREATE TABLE app_settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL,
  updated_at TEXT NOT NULL
);
```

DeepSeek API Key 不放这张表，使用 `flutter_secure_storage`。

## 5. AI 接入设计

### 5.1 DeepSeek API 现状

DeepSeek 官方文档说明其 API 兼容 OpenAI/Anthropic 格式，OpenAI 兼容 `base_url` 为：

```text
https://api.deepseek.com
```

官方示例调用：

```text
POST /chat/completions
```

模型示例：
- `deepseek-v4-flash`
- `deepseek-v4-pro`

注意：图片输入能力需要按实际 DeepSeek 账号和模型能力验证。如果当前官方 API 或账号模型不支持图片输入，App 侧保留同一套 `AiAnalysisService` 接口，后续替换为可用的 DeepSeek 视觉模型或兼容视觉端点。

### 5.2 API Key 存储

第一版直接客户端接入 DeepSeek，API Key 风险如下：
- App 包可能被反编译。
- Key 可能被抓包或越狱环境读取。
- 无法服务端统一限流。

MVP 接受该风险，但不把 Key 写死到代码。

设计：
- 我的页新增“AI 设置”入口。
- 用户手动输入 DeepSeek API Key。
- 使用 `flutter_secure_storage` 保存。
- 调用 API 时从 secure storage 读取。

### 5.3 AI 服务接口

Dart 层抽象：

```dart
abstract class AiAnalysisService {
  Future<DietAnalysisResult> analyzeDietImage({
    required Uint8List imageBytes,
    required String mealType,
  });

  Future<ExerciseAnalysisResult> analyzeExerciseScreenshot({
    required Uint8List imageBytes,
  });

  Future<DailyPlanResult> generateDailyPlan({
    required UserProfile profile,
    required DailyContext context,
  });

  Future<UpdatedPlanResult> updatePlanByHistory({
    required UserProfile profile,
    required List<DailySummary> recentSummaries,
  });
}
```

### 5.4 饮食图片解析输出

AI 必须返回 JSON。

```json
{
  "items": [
    {
      "food_name": "米饭",
      "portion_level": "normal",
      "calories": 280,
      "confidence": 0.82
    }
  ],
  "total_calories": 680,
  "summary": "主食偏多，蛋白质中等，蔬菜不足。",
  "warnings": ["图片角度可能影响份量估算"]
}
```

保存策略：
- 用户确认后，将 `items` 拆成多条 `diet_records`。
- `total_calories` 用于界面展示，不单独作为记录保存。
- 原图不保存。

### 5.5 运动截图解析输出

```json
{
  "exercise_type": "快走",
  "duration_minutes": 30,
  "distance_km": 2.4,
  "calories_burned": 180,
  "confidence": 0.88,
  "summary": "中等强度快走，适合今日轻量消耗。"
}
```

保存策略：
- 用户确认后保存一条 `exercise_records`。
- 原截图不保存。

### 5.6 图片临时处理

流程：

1. `image_picker` 获取图片。
2. 读取为 `Uint8List`。
3. 使用 `image` 包压缩尺寸。
4. 控制最长边，例如 1280px。
5. 转成 DeepSeek 所需格式。
6. 请求结束后释放内存引用。
7. 不写入应用文档目录。

如果 iOS 相机插件生成了临时文件：
- 成功解析后尝试删除临时文件。
- 删除失败不阻断用户流程。

## 6. 页面与路由设计

### 6.1 路由列表

```text
/splash                 启动页
/login                  登录页
/profile-setup          基础信息页
/home                   首页
/diet/photo             饮食识别页
/diet/manual            手动饮食记录页
/exercise/screenshot    运动识别页
/recommend              推荐页
/history                历史记录页
/day-detail/:date       单日详情页
/mine                   我的页
/ai-settings            AI 设置页
```

### 6.2 启动分流

```text
打开 App
  -> 是否有本地 user_profile
    -> 无：启动页 -> 登录页 -> 基础信息页
    -> 有：进入首页
```

说明：
- 第一版手机号不做真实短信验证，可先本地模拟。
- 后续接服务端时，登录流程替换为真实验证码登录。

### 6.3 首页

首页数据来源：
- `user_profile`
- 今日 `diet_records`
- 今日 `exercise_records`
- 今日 `daily_plans`
- 昨日 `daily_summaries`

首页展示：
- 目标进度。
- 今日进度。
- 昨日回顾。
- 今日计划。
- 快捷操作。

点击：
- 今日进度 -> `/day-detail/today`
- 昨日回顾 -> `/day-detail/yesterday`
- 手动记饮食 -> `/diet/manual`
- 拍照记饮食 -> `/diet/photo`
- 上传运动截图 -> `/exercise/screenshot`

### 6.4 手动饮食记录页

输入：
- 餐次。
- 食物名称。
- 份量。
- 热量。
- 备注。

交互：
- 点击“AI 估算热量”时，调用 DeepSeek 文本接口估算。
- 点击“添加”加入本餐临时列表。
- 点击“保存到今日记录”批量写入 `diet_records`。

### 6.5 单日详情页

只读。

展示：
- 日期。
- 摄入合计。
- 消耗合计。
- 净摄入。
- 饮食记录列表。
- 运动记录列表。
- AI 总结。

不提供编辑入口。

## 7. 本地计算规则

### 7.1 今日摄入

```text
today_intake = sum(diet_records.calories where record_date = today)
```

### 7.2 今日消耗

```text
today_burned = sum(exercise_records.calories_burned where record_date = today)
```

### 7.3 净摄入

```text
net_intake = intake_calories - burned_calories
```

### 7.4 状态判断

```text
if intake < daily_calorie_min * 0.85:
  摄入偏低
else if intake <= daily_calorie_max:
  控制良好
else if intake <= daily_calorie_max * 1.15:
  略超标
else:
  超标
```

运动消耗用于辅助文案，不直接鼓励“吃多了就惩罚式运动”。

## 8. 目录结构

```text
lib/
  main.dart
  app.dart
  core/
    constants/
    database/
    router/
    theme/
    utils/
  features/
    auth/
      pages/
      providers/
    profile/
      pages/
      models/
      repositories/
    home/
      pages/
      providers/
    diet/
      pages/
      models/
      repositories/
    exercise/
      pages/
      models/
      repositories/
    plan/
      pages/
      models/
      repositories/
    history/
      pages/
      providers/
    mine/
      pages/
    ai/
      models/
      services/
      prompts/
```

## 9. 状态管理设计

使用 Riverpod。

核心 Provider：

```text
databaseProvider
userProfileProvider
todaySummaryProvider
todayPlanProvider
historyProvider
aiSettingsProvider
aiAnalysisServiceProvider
```

页面只消费 Provider，不直接操作数据库。

## 10. 错误处理

### 10.1 DeepSeek 未配置 Key

提示：

```text
请先在 我的 -> AI 设置 中配置 DeepSeek API Key
```

### 10.2 AI 解析失败

处理：
- 展示失败原因。
- 保留“手动记录”入口。
- 不保存图片。

### 10.3 JSON 解析失败

处理：
- 尝试提取文本中的 JSON。
- 仍失败则提示用户手动记录。
- 记录本地 debug log，第一版只在控制台输出。

### 10.4 网络失败

处理：
- 提示网络异常。
- 允许重试。
- 允许转手动记录。

## 11. 隐私与安全

第一版隐私原则：
- 图片只用于本次 AI 解析。
- App 不长期保存原图。
- 本地只保存结构化记录。
- API Key 存在安全存储，不写死代码。

用户提示：
- 在拍照识别页明确提示“图片仅用于本次 AI 分析，分析完成后不保存原图”。
- 在我的页提供隐私政策入口。

风险：
- 客户端直连 DeepSeek 会暴露 API Key 风险。
- 如果后续公开发布，必须迁移为“App -> 服务端 -> DeepSeek”。

## 12. 开发里程碑

### 阶段 1：工程和基础壳

- 创建 Flutter iOS 项目。
- 建立主题、路由、底部导航。
- 完成启动页、登录页、基础信息页。
- SQLite 初始化。

### 阶段 2：本地记录闭环

- 首页。
- 手动饮食记录。
- 饮食记录保存。
- 运动记录手动保存。
- 历史记录。
- 单日详情。

### 阶段 3：AI 图片解析

- DeepSeek API Key 设置。
- 拍照/选图。
- 饮食图片 AI 解析。
- 运动截图 AI 解析。
- 用户确认后保存结构化数据。
- 图片不保存。

### 阶段 4：计划和推荐

- 今日计划。
- 明日计划。
- 7 天计划日历。
- 根据历史更新计划。

### 阶段 5：真机验证

- iPhone 真机运行。
- 相机权限。
- 相册权限。
- 网络权限。
- SQLite 数据检查。
- 断网和 AI 失败降级。

## 13. 待确认问题

1. DeepSeek 当前 API Key 是否支持图片输入。
2. 如果不支持图片输入，是否接受先用 DeepSeek 文本能力 + 手动记录，或更换支持视觉的 DeepSeek 兼容端点。
3. 手机号登录第一版是否完全本地模拟。
4. 是否需要给“AI 设置”单独出原型页。
