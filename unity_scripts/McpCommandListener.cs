using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

[Serializable]
public class McpCommand
{
    public string id;
    public string type;
    public int playerIndex;
    public int steps;
    public int targetTile;
    public string status;
    public string result;
    public string timestamp;
}

[Serializable]
public class McpCommandFile
{
    public List<McpCommand> commands = new List<McpCommand>();
}

public class McpCommandListener : MonoBehaviour
{
    [Header("Board Layout")]
    public int boardSize = 26;
    public float tileSize = 1f;
    public float spacing = 0.1f;

    [Header("Animation")]
    public float hopHeight = 0.5f;
    public float hopDuration = 0.45f;
    public float passingStartDelay = 0.6f;
    public int passingStartBonus = 5;
    public int startPosition = 0;

    [Header("File")]
    public string commandFileName = "unity_commands.json";
    public float pollInterval = 0.1f;

    private string CommandFilePath =>
        Path.Combine(Application.dataPath, "..", commandFileName);

    private Dictionary<int, Transform> playerPawns = new Dictionary<int, Transform>();
    private Dictionary<int, int> playerPositions = new Dictionary<int, int>();
    private Queue<McpCommand> commandQueue = new Queue<McpCommand>();
    private bool isProcessing;
    private FileSystemWatcher watcher;
    private volatile bool fileChanged;
    private float pollTimer;
    private string lastFileHash;

    private void Start()
    {
        FindPlayerPawns();
        InitializeCommandFile();
        StartFileWatcher();
        StartCoroutine(PollLoop());
    }

    private void OnDestroy()
    {
        if (watcher != null)
        {
            watcher.EnableRaisingEvents = false;
            watcher.Dispose();
        }
    }

    private void FindPlayerPawns()
    {
        playerPawns.Clear();
        playerPositions.Clear();

        for (int i = 0; i < 4; i++)
        {
            GameObject pawn = GameObject.Find($"Player{i}");
            if (pawn == null) pawn = GameObject.Find($"Pawn_{i}");
            if (pawn == null) pawn = GameObject.Find($"Player_{i}");

            if (pawn != null)
            {
                playerPawns[i] = pawn.transform;
                playerPositions[i] = 0;
                Debug.Log($"[McpBridge] Found pawn: {pawn.name} -> index {i}");
            }
        }

        if (playerPawns.Count == 0)
        {
            GameObject[] tagged = GameObject.FindGameObjectsWithTag("Player");
            for (int i = 0; i < tagged.Length && i < 4; i++)
            {
                playerPawns[i] = tagged[i].transform;
                playerPositions[i] = 0;
                Debug.Log($"[McpBridge] Found tagged pawn: {tagged[i].name} -> index {i}");
            }
        }

        Debug.Log($"[McpBridge] Total pawns found: {playerPawns.Count}");
    }

    private void InitializeCommandFile()
    {
        try
        {
            if (!File.Exists(CommandFilePath))
            {
                McpCommandFile data = new McpCommandFile();
                File.WriteAllText(CommandFilePath, JsonUtility.ToJson(data, true));
                Debug.Log($"[McpBridge] Created command file: {CommandFilePath}");
            }
        }
        catch (Exception e)
        {
            Debug.LogError($"[McpBridge] Init error: {e.Message}");
        }
    }

    private void StartFileWatcher()
    {
        try
        {
            string dir = Path.GetDirectoryName(CommandFilePath);
            string fileName = Path.GetFileName(CommandFilePath);

            if (!Directory.Exists(dir)) return;

            watcher = new FileSystemWatcher(dir, fileName)
            {
                NotifyFilter = NotifyFilters.LastWrite | NotifyFilters.Size
            };
            watcher.Changed += (_, _) => fileChanged = true;
            watcher.EnableRaisingEvents = true;

            Debug.Log($"[McpBridge] Watching: {CommandFilePath}");
        }
        catch (Exception e)
        {
            Debug.LogWarning($"[McpBridge] FileSystemWatcher failed, using poll: {e.Message}");
        }
    }

    private IEnumerator PollLoop()
    {
        while (true)
        {
            yield return new WaitForSeconds(pollInterval);

            pollTimer += pollInterval;
            if (!fileChanged && pollTimer < 2f) continue;

            pollTimer = 0f;
            fileChanged = false;
            ReadAndEnqueueCommands();
        }
    }

    private void ReadAndEnqueueCommands()
    {
        try
        {
            string json = ReadFileWithRetry();
            if (string.IsNullOrEmpty(json)) return;

            string hash = json.GetHashCode().ToString();
            if (hash == lastFileHash) return;
            lastFileHash = hash;

            McpCommandFile data = JsonUtility.FromJson<McpCommandFile>(json);
            if (data?.commands == null) return;

            bool dirty = false;
            foreach (McpCommand cmd in data.commands)
            {
                if (cmd.status != "pending") continue;

                cmd.status = "processing";
                dirty = true;
                commandQueue.Enqueue(cmd);
                Debug.Log($"[McpBridge] Queued: {cmd.type} id={cmd.id}");
            }

            if (dirty) WriteCommands(data);
        }
        catch (Exception e)
        {
            Debug.LogError($"[McpBridge] Read error: {e.Message}");
        }
    }

    private string ReadFileWithRetry()
    {
        for (int i = 0; i < 3; i++)
        {
            try
            {
                return File.ReadAllText(CommandFilePath);
            }
            catch (IOException)
            {
                System.Threading.Thread.Sleep(50);
            }
        }
        return null;
    }

    private void Update()
    {
        if (isProcessing || commandQueue.Count == 0) return;
        McpCommand cmd = commandQueue.Dequeue();
        StartCoroutine(ProcessCommand(cmd));
    }

    private IEnumerator ProcessCommand(McpCommand cmd)
    {
        isProcessing = true;
        Debug.Log($"[McpBridge] Processing: {cmd.type}");

        switch (cmd.type)
        {
            case "move_pawn":
                yield return ExecuteMovePawn(cmd);
                break;
            case "move_pawn_to":
                yield return ExecuteMovePawnTo(cmd);
                break;
            case "reset_pawns":
                yield return ExecuteResetPawns(cmd);
                break;
            default:
                cmd.status = "error";
                cmd.result = $"Unknown command type: {cmd.type}";
                break;
        }

        UpdateCommandInFile(cmd);
        isProcessing = false;
    }

    private IEnumerator ExecuteMovePawn(McpCommand cmd)
    {
        int pIdx = cmd.playerIndex;
        if (!playerPawns.ContainsKey(pIdx))
        {
            cmd.status = "error";
            cmd.result = $"Player {pIdx} not found";
            yield break;
        }

        Transform pawn = playerPawns[pIdx];
        int currentPos = playerPositions[pIdx];
        int steps = Mathf.Max(1, cmd.steps);

        Debug.Log($"[McpBridge] Moving player {pIdx}: pos {currentPos} + {steps} steps");

        for (int i = 0; i < steps; i++)
        {
            currentPos = (currentPos + 1) % boardSize;

            bool isLastStep = (i == steps - 1);
            if (currentPos == startPosition && !isLastStep)
            {
                Debug.Log($"[McpBridge] Player {pIdx} passed start! +{passingStartBonus} stars");
                yield return new WaitForSeconds(passingStartDelay);
            }

            Vector3 target = GetWorldPosition(currentPos);
            yield return StartCoroutine(HopTo(pawn, target));

            playerPositions[pIdx] = currentPos;
        }

        cmd.status = "completed";
        cmd.result = $"Player {pIdx} moved to tile {currentPos}";
        Debug.Log($"[McpBridge] {cmd.result}");
    }

    private IEnumerator ExecuteMovePawnTo(McpCommand cmd)
    {
        int pIdx = cmd.playerIndex;
        if (!playerPawns.ContainsKey(pIdx))
        {
            cmd.status = "error";
            cmd.result = $"Player {pIdx} not found";
            yield break;
        }

        Transform pawn = playerPawns[pIdx];
        int targetTile = Mathf.Clamp(cmd.targetTile, 0, boardSize - 1);
        int currentPos = playerPositions[pIdx];

        if (currentPos == targetTile)
        {
            cmd.status = "completed";
            cmd.result = $"Player {pIdx} already at tile {targetTile}";
            yield break;
        }

        int stepsToMove = targetTile > currentPos
            ? targetTile - currentPos
            : boardSize - currentPos + targetTile;

        for (int i = 0; i < stepsToMove; i++)
        {
            currentPos = (currentPos + 1) % boardSize;
            Vector3 target = GetWorldPosition(currentPos);
            yield return StartCoroutine(HopTo(pawn, target));
            playerPositions[pIdx] = currentPos;
        }

        cmd.status = "completed";
        cmd.result = $"Player {pIdx} moved to tile {targetTile}";
    }

    private IEnumerator ExecuteResetPawns(McpCommand cmd)
    {
        Vector3 startPos = GetWorldPosition(startPosition);
        foreach (var kvp in playerPawns)
        {
            kvp.Value.position = startPos;
            playerPositions[kvp.Key] = startPosition;
            yield return new WaitForSeconds(0.1f);
        }
        cmd.status = "completed";
        cmd.result = "All pawns reset to start";
    }

    private IEnumerator HopTo(Transform pawn, Vector3 target)
    {
        Vector3 start = pawn.position;
        float elapsed = 0f;

        while (elapsed < hopDuration)
        {
            elapsed += Time.deltaTime;
            float t = Mathf.Clamp01(elapsed / hopDuration);

            Vector3 pos = Vector3.Lerp(start, target, t);
            pos.y += hopHeight * Mathf.Sin(t * Mathf.PI);
            pawn.position = pos;

            yield return null;
        }

        pawn.position = new Vector3(target.x, 0f, target.z);
    }

    private void UpdateCommandInFile(McpCommand completedCmd)
    {
        try
        {
            string json = ReadFileWithRetry();
            if (string.IsNullOrEmpty(json)) return;

            McpCommandFile data = JsonUtility.FromJson<McpCommandFile>(json);
            if (data?.commands == null) return;

            foreach (McpCommand cmd in data.commands)
            {
                if (cmd.id == completedCmd.id)
                {
                    cmd.status = completedCmd.status;
                    cmd.result = completedCmd.result;
                    break;
                }
            }

            WriteCommands(data);
            lastFileHash = null;
        }
        catch (Exception e)
        {
            Debug.LogError($"[McpBridge] Update error: {e.Message}");
        }
    }

    private void WriteCommands(McpCommandFile data)
    {
        try
        {
            string json = JsonUtility.ToJson(data, true);
            File.WriteAllText(CommandFilePath, json);
        }
        catch (Exception e)
        {
            Debug.LogError($"[McpBridge] Write error: {e.Message}");
        }
    }

    public Vector3 GetWorldPosition(int index)
    {
        float step = tileSize + spacing;

        if (index >= 0 && index <= 6)
            return new Vector3((6 - index) * step, 0f, 0f);

        if (index >= 7 && index <= 13)
            return new Vector3(0f, 0f, (index - 6) * step);

        if (index >= 14 && index <= 19)
            return new Vector3((index - 13) * step, 0f, 7f * step);

        if (index >= 20 && index <= 25)
            return new Vector3(6f * step, 0f, (26 - index) * step);

        return Vector3.zero;
    }

    public int GetPlayerPosition(int playerIndex)
    {
        return playerPositions.GetValueOrDefault(playerIndex, -1);
    }

    public void ForceSetPlayerPosition(int playerIndex, int tile)
    {
        if (!playerPawns.ContainsKey(playerIndex)) return;
        playerPositions[playerIndex] = Mathf.Clamp(tile, 0, boardSize - 1);
        playerPawns[playerIndex].position = GetWorldPosition(playerPositions[playerIndex]);
    }
}
