using UnityEngine;

#if UNITY_EDITOR
using TMPro;
#endif

public class TileLabel : MonoBehaviour
{
    [Header("Tile Info")]
    public string tileName;
    public int tileIndex;
    public TileType tileType;
    public Difficulty difficulty;

#if UNITY_EDITOR
    [ContextMenu("Create Label")]
    public void CreateLabel()
    {
        GameObject labelObj = new GameObject("Label");
        labelObj.transform.SetParent(transform);
        labelObj.transform.localPosition = new Vector3(0f, 0.6f, 0f);
        labelObj.transform.localRotation = Quaternion.Euler(90f, 0f, 0f);

        TextMeshPro tmp = labelObj.AddComponent<TextMeshPro>();
        tmp.text = tileName;
        tmp.fontSize = 14;
        tmp.alignment = TextAlignmentOptions.Center;
        tmp.color = Color.black;
        tmp.autoSizeTextContainer = true;
    }
#endif
}
