import styles from './layout.module.scss';

export default function ContentBlock(props) {
  const hasHeading = props.heading;

  return (
    <section className={styles.innerContentGrid}>
      {hasHeading != null ? <h2 style={{ marginBottom: 0 }}>{props.heading}</h2> : null}
      <p>{props.content}</p>
      {props.children}
    </section>
  );
}